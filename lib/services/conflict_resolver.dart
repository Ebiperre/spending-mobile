import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/sync_models.dart';
import 'database_service.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Conflict resolution strategy
enum ConflictStrategy {
  /// Server version always wins
  serverWins,

  /// Local version always wins
  localWins,

  /// Most recent update wins (based on timestamp)
  lastWriteWins,

  /// Manual resolution required
  manual,
}

/// Result of conflict resolution
class ConflictResult {
  final bool resolved;
  final String? winner; // 'local' or 'server'
  final LocalTransaction? resolvedTransaction;
  final String? error;

  ConflictResult({
    required this.resolved,
    this.winner,
    this.resolvedTransaction,
    this.error,
  });

  factory ConflictResult.success({
    required String winner,
    required LocalTransaction transaction,
  }) {
    return ConflictResult(
      resolved: true,
      winner: winner,
      resolvedTransaction: transaction,
    );
  }

  factory ConflictResult.failure(String error) {
    return ConflictResult(
      resolved: false,
      error: error,
    );
  }
}

/// Service for handling sync conflicts
class ConflictResolver {
  static final ConflictResolver _instance = ConflictResolver._internal();
  factory ConflictResolver() => _instance;
  ConflictResolver._internal();

  final DatabaseService _db = DatabaseService();
  final ApiClient _api = ApiClient();

  /// Default conflict strategy
  ConflictStrategy _defaultStrategy = ConflictStrategy.lastWriteWins;

  /// Set default conflict strategy
  set defaultStrategy(ConflictStrategy strategy) {
    _defaultStrategy = strategy;
  }

  /// Get default conflict strategy
  ConflictStrategy get defaultStrategy => _defaultStrategy;

  /// Resolve a transaction conflict
  Future<ConflictResult> resolveTransactionConflict({
    required LocalTransaction localTransaction,
    required Map<String, dynamic> serverData,
    ConflictStrategy? strategy,
  }) async {
    final effectiveStrategy = strategy ?? _defaultStrategy;

    try {
      switch (effectiveStrategy) {
        case ConflictStrategy.serverWins:
          return await _applyServerVersion(localTransaction, serverData);

        case ConflictStrategy.localWins:
          return await _applyLocalVersion(localTransaction);

        case ConflictStrategy.lastWriteWins:
          return await _applyLastWriteWins(localTransaction, serverData);

        case ConflictStrategy.manual:
          // Return unresolved for manual handling
          return ConflictResult(
            resolved: false,
            error: 'Manual resolution required',
          );
      }
    } catch (e) {
      debugPrint('ConflictResolver: Error resolving conflict: $e');
      return ConflictResult.failure(e.toString());
    }
  }

  /// Apply server version (server wins)
  Future<ConflictResult> _applyServerVersion(
    LocalTransaction localTransaction,
    Map<String, dynamic> serverData,
  ) async {
    debugPrint('ConflictResolver: Applying server version');

    // Update local transaction with server data
    localTransaction.amount = (serverData['amount'] as num).toDouble();
    localTransaction.category = serverData['category'] ?? localTransaction.category;
    localTransaction.description = serverData['description'];
    localTransaction.type = serverData['type'] ?? localTransaction.type;

    if (serverData['transactionDate'] != null) {
      localTransaction.transactionDate = DateTime.parse(serverData['transactionDate']);
    }

    if (serverData['updatedAt'] != null) {
      localTransaction.updatedAt = DateTime.parse(serverData['updatedAt']);
    }

    localTransaction.serverVersion = serverData['version'] ?? localTransaction.serverVersion + 1;
    localTransaction.syncStatus = SyncStatus.synced;
    localTransaction.lastSyncAttempt = DateTime.now();
    localTransaction.lastSyncError = null;

    await _db.saveTransaction(localTransaction);

    return ConflictResult.success(
      winner: 'server',
      transaction: localTransaction,
    );
  }

  /// Apply local version (local wins)
  Future<ConflictResult> _applyLocalVersion(
    LocalTransaction localTransaction,
  ) async {
    debugPrint('ConflictResolver: Applying local version');

    // Keep local data, mark as pending for re-sync
    localTransaction.syncStatus = SyncStatus.pending;
    localTransaction.localVersion++;

    await _db.saveTransaction(localTransaction);

    return ConflictResult.success(
      winner: 'local',
      transaction: localTransaction,
    );
  }

  /// Apply last write wins strategy
  Future<ConflictResult> _applyLastWriteWins(
    LocalTransaction localTransaction,
    Map<String, dynamic> serverData,
  ) async {
    final serverUpdatedAt = serverData['updatedAt'] != null
        ? DateTime.parse(serverData['updatedAt'])
        : DateTime.now();

    debugPrint(
      'ConflictResolver: Comparing timestamps - Local: ${localTransaction.updatedAt}, Server: $serverUpdatedAt',
    );

    if (localTransaction.updatedAt.isAfter(serverUpdatedAt)) {
      // Local is more recent
      return await _applyLocalVersion(localTransaction);
    } else {
      // Server is more recent
      return await _applyServerVersion(localTransaction, serverData);
    }
  }

  /// Fetch server version and resolve conflict
  Future<ConflictResult> fetchAndResolveConflict({
    required LocalTransaction localTransaction,
    ConflictStrategy? strategy,
  }) async {
    if (localTransaction.serverId == null) {
      return ConflictResult.failure('No server ID for conflict resolution');
    }

    try {
      final response = await _api.get('${ApiConfig.transactions}/${localTransaction.serverId}');

      if (response['success'] == true && response['data'] != null) {
        return await resolveTransactionConflict(
          localTransaction: localTransaction,
          serverData: response['data'],
          strategy: strategy,
        );
      } else if (response['statusCode'] == 404) {
        // Server record deleted, delete locally
        await _db.deleteTransactionByLocalId(localTransaction.localId);
        return ConflictResult(
          resolved: true,
          winner: 'server',
          error: 'Server record deleted',
        );
      } else {
        return ConflictResult.failure(
          response['error'] ?? 'Failed to fetch server version',
        );
      }
    } catch (e) {
      return ConflictResult.failure(e.toString());
    }
  }

  /// Merge transactions from server with local data
  Future<MergeResult> mergeServerTransactions(
    List<Map<String, dynamic>> serverTransactions,
  ) async {
    int created = 0;
    int updated = 0;
    int conflicts = 0;

    for (final serverData in serverTransactions) {
      final serverId = serverData['id']?.toString();
      if (serverId == null) continue;

      final localTransaction = await _db.getTransactionByServerId(serverId);

      if (localTransaction == null) {
        // New transaction from server, create locally
        final newTransaction = LocalTransaction()
          ..localId = 'server_$serverId'
          ..serverId = serverId
          ..amount = (serverData['amount'] as num).toDouble()
          ..category = serverData['category'] ?? 'Other'
          ..description = serverData['description']
          ..transactionDate = DateTime.parse(serverData['transactionDate'])
          ..type = serverData['type'] ?? 'expense'
          ..createdAt = serverData['createdAt'] != null
              ? DateTime.parse(serverData['createdAt'])
              : DateTime.now()
          ..updatedAt = serverData['updatedAt'] != null
              ? DateTime.parse(serverData['updatedAt'])
              : DateTime.now()
          ..syncStatus = SyncStatus.synced
          ..serverVersion = serverData['version'] ?? 1;

        await _db.saveTransaction(newTransaction);
        created++;
      } else if (localTransaction.syncStatus == SyncStatus.synced) {
        // Local is synced, safe to update from server
        final serverVersion = serverData['version'] ?? 0;
        if (serverVersion > localTransaction.serverVersion) {
          localTransaction.amount = (serverData['amount'] as num).toDouble();
          localTransaction.category = serverData['category'] ?? localTransaction.category;
          localTransaction.description = serverData['description'];
          localTransaction.transactionDate = DateTime.parse(serverData['transactionDate']);
          localTransaction.type = serverData['type'] ?? localTransaction.type;
          localTransaction.updatedAt = serverData['updatedAt'] != null
              ? DateTime.parse(serverData['updatedAt'])
              : DateTime.now();
          localTransaction.serverVersion = serverVersion;

          await _db.saveTransaction(localTransaction);
          updated++;
        }
      } else if (localTransaction.syncStatus == SyncStatus.pending) {
        // Local has pending changes, potential conflict
        final result = await resolveTransactionConflict(
          localTransaction: localTransaction,
          serverData: serverData,
        );

        if (result.resolved) {
          if (result.winner == 'server') {
            updated++;
          }
        } else {
          conflicts++;
        }
      }
      // Skip failed/deleted transactions
    }

    return MergeResult(
      created: created,
      updated: updated,
      conflicts: conflicts,
    );
  }

  /// Detect local transactions that were deleted on server
  Future<int> detectServerDeletions(List<String> serverIds) async {
    int deleted = 0;

    // Get all synced local transactions
    final allTransactions = await _db.isar.localTransactions.where().sortByCreatedAt().findAll();
    final localTransactions = allTransactions
        .where((t) => t.syncStatus == SyncStatus.synced && t.serverId != null)
        .toList();

    for (final transaction in localTransactions) {
      if (!serverIds.contains(transaction.serverId)) {
        // Server no longer has this transaction
        await _db.deleteTransactionByLocalId(transaction.localId);
        deleted++;
        debugPrint('ConflictResolver: Deleted locally (server deletion): ${transaction.serverId}');
      }
    }

    return deleted;
  }
}

/// Result of merging server data
class MergeResult {
  final int created;
  final int updated;
  final int conflicts;

  MergeResult({
    required this.created,
    required this.updated,
    required this.conflicts,
  });

  @override
  String toString() {
    return 'MergeResult(created: $created, updated: $updated, conflicts: $conflicts)';
  }
}
