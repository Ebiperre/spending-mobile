import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/sync_models.dart';
import 'database_service.dart';
import 'connectivity_service.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Sync state enum
enum SyncState {
  idle,
  syncing,
  synced,
  error,
}

/// Service for managing the sync queue
class SyncQueueService extends ChangeNotifier {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiClient _api = ApiClient();

  SyncState _state = SyncState.idle;
  int _pendingCount = 0;
  int _failedCount = 0;
  String? _lastError;
  bool _isProcessing = false;
  Timer? _retryTimer;

  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;

  /// Retry delay in seconds
  static const int retryDelaySeconds = 30;

  /// Current sync state
  SyncState get state => _state;

  /// Number of pending items
  int get pendingCount => _pendingCount;

  /// Number of failed items
  int get failedCount => _failedCount;

  /// Last error message
  String? get lastError => _lastError;

  /// Check if currently syncing
  bool get isSyncing => _state == SyncState.syncing;

  /// Initialize the sync queue service
  Future<void> init() async {
    // Update counts
    await _updateCounts();

    // Listen for connectivity changes
    _connectivity.onOnline(_onConnectivityRestored);

    // Start retry timer for failed items
    _startRetryTimer();
  }

  /// Called when connectivity is restored
  void _onConnectivityRestored() {
    debugPrint('SyncQueueService: Connectivity restored, processing queue');
    processQueue();
  }

  /// Start the retry timer
  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(
      const Duration(seconds: retryDelaySeconds),
      (_) => _retryFailedItems(),
    );
  }

  /// Retry failed items
  Future<void> _retryFailedItems() async {
    if (!_connectivity.isOnline || _isProcessing) return;

    // Get all transactions and filter for failed ones with retry attempts available
    final allTransactions = await _db.isar.localTransactions.where().sortByCreatedAt().findAll();
    final failedTransactions = allTransactions
        .where((t) => t.syncStatus == SyncStatus.failed && t.syncAttempts < maxRetryAttempts)
        .toList();

    if (failedTransactions.isEmpty) return;

    debugPrint('SyncQueueService: Retrying ${failedTransactions.length} failed items');

    for (final transaction in failedTransactions) {
      // Re-queue for sync
      transaction.syncStatus = SyncStatus.pending;
      await _db.saveTransaction(transaction);
    }

    await _updateCounts();
    processQueue();
  }

  /// Update pending and failed counts
  Future<void> _updateCounts() async {
    _pendingCount = await _db.getPendingTransactionsCount();
    _failedCount = await _db.getFailedTransactionsCount();

    // Update state
    if (_pendingCount == 0 && _failedCount == 0) {
      _state = SyncState.synced;
    } else if (_failedCount > 0 && _pendingCount == 0) {
      _state = SyncState.error;
    } else if (_pendingCount > 0) {
      _state = SyncState.idle;
    }

    notifyListeners();
  }

  /// Add a transaction to the sync queue
  Future<void> queueTransaction(
    LocalTransaction transaction,
    SyncOperation operation,
  ) async {
    // Set sync status
    transaction.syncStatus = SyncStatus.pending;
    transaction.syncAttempts = 0;
    transaction.lastSyncError = null;
    await _db.saveTransaction(transaction);

    // Add to sync queue
    final queueItem = SyncQueueItem()
      ..entityType = 'transaction'
      ..localId = transaction.localId
      ..operation = operation
      ..payload = ''
      ..createdAt = DateTime.now()
      ..priority = _getPriority(operation);

    await _db.addToSyncQueue(queueItem);
    await _updateCounts();

    // Try to sync immediately if online
    if (_connectivity.isOnline) {
      processQueue();
    }
  }

  /// Get priority for operation (lower = higher priority)
  int _getPriority(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.create:
        return 1;
      case SyncOperation.delete:
        return 2;
      case SyncOperation.update:
        return 3;
    }
  }

  /// Process the sync queue
  Future<void> processQueue() async {
    if (_isProcessing) return;
    if (!_connectivity.isOnline) {
      debugPrint('SyncQueueService: Offline, skipping queue processing');
      return;
    }

    _isProcessing = true;
    _state = SyncState.syncing;
    _lastError = null;
    notifyListeners();

    try {
      final queueItems = await _db.getPendingSyncItems();
      debugPrint('SyncQueueService: Processing ${queueItems.length} items');

      for (final item in queueItems) {
        if (!_connectivity.isOnline) {
          debugPrint('SyncQueueService: Lost connectivity, stopping');
          break;
        }

        await _processItem(item);
      }

      await _updateCounts();
    } catch (e) {
      debugPrint('SyncQueueService: Error processing queue: $e');
      _lastError = e.toString();
      _state = SyncState.error;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Process a single queue item
  Future<void> _processItem(SyncQueueItem item) async {
    try {
      switch (item.entityType) {
        case 'transaction':
          await _syncTransaction(item);
          break;
        default:
          debugPrint('SyncQueueService: Unknown entity type: ${item.entityType}');
          await _db.removeFromSyncQueue(item.id);
      }
    } catch (e) {
      debugPrint('SyncQueueService: Error processing item ${item.id}: $e');
      await _handleSyncError(item, e.toString());
    }
  }

  /// Sync a transaction
  Future<void> _syncTransaction(SyncQueueItem item) async {
    final transaction = await _db.getTransactionByLocalId(item.localId);
    if (transaction == null) {
      debugPrint('SyncQueueService: Transaction not found: ${item.localId}');
      await _db.removeFromSyncQueue(item.id);
      return;
    }

    try {
      switch (item.operation) {
        case SyncOperation.create:
          await _createTransactionOnServer(transaction, item);
          break;
        case SyncOperation.update:
          await _updateTransactionOnServer(transaction, item);
          break;
        case SyncOperation.delete:
          await _deleteTransactionOnServer(transaction, item);
          break;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create transaction on server
  Future<void> _createTransactionOnServer(
    LocalTransaction transaction,
    SyncQueueItem item,
  ) async {
    final response = await _api.post(
      ApiConfig.transactions,
      body: {
        'amount': transaction.amount,
        'category': transaction.category,
        'description': transaction.description,
        'date': transaction.transactionDate.toIso8601String(),
        'type': transaction.type,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      // Update local transaction with server ID
      transaction.serverId = response['data']['id']?.toString();
      transaction.syncStatus = SyncStatus.synced;
      transaction.lastSyncAttempt = DateTime.now();
      transaction.serverVersion = response['data']['version'] ?? 1;
      await _db.saveTransaction(transaction);

      // Remove from queue
      await _db.removeFromSyncQueue(item.id);
      debugPrint('SyncQueueService: Created transaction on server: ${transaction.serverId}');
    } else {
      throw Exception(response['error'] ?? 'Failed to create transaction');
    }
  }

  /// Update transaction on server
  Future<void> _updateTransactionOnServer(
    LocalTransaction transaction,
    SyncQueueItem item,
  ) async {
    if (transaction.serverId == null) {
      // No server ID, treat as create
      await _createTransactionOnServer(transaction, item);
      return;
    }

    try {
      final response = await _api.put(
        '${ApiConfig.transactions}/${transaction.serverId}',
        body: {
          'amount': transaction.amount,
          'category': transaction.category,
          'description': transaction.description,
          'date': transaction.transactionDate.toIso8601String(),
          'type': transaction.type,
        },
      );

      if (response['success'] == true) {
        transaction.syncStatus = SyncStatus.synced;
        transaction.lastSyncAttempt = DateTime.now();
        transaction.serverVersion = response['data']?['version'] ?? transaction.serverVersion + 1;
        await _db.saveTransaction(transaction);

        await _db.removeFromSyncQueue(item.id);
        debugPrint('SyncQueueService: Updated transaction on server: ${transaction.serverId}');
      } else {
        throw Exception(response['error'] ?? 'Failed to update transaction');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // Conflict - handle separately
        await _handleConflict(transaction, item);
      } else {
        rethrow;
      }
    }
  }

  /// Delete transaction on server
  Future<void> _deleteTransactionOnServer(
    LocalTransaction transaction,
    SyncQueueItem item,
  ) async {
    if (transaction.serverId == null) {
      // Never synced, just delete locally
      await _db.deleteTransactionByLocalId(transaction.localId);
      await _db.removeFromSyncQueue(item.id);
      return;
    }

    try {
      final response = await _api.delete('${ApiConfig.transactions}/${transaction.serverId}');

      if (response['success'] == true) {
        // Delete locally
        await _db.deleteTransactionByLocalId(transaction.localId);
        await _db.removeFromSyncQueue(item.id);
        debugPrint('SyncQueueService: Deleted transaction: ${transaction.serverId}');
      } else {
        throw Exception(response['error'] ?? 'Failed to delete transaction');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // Already deleted on server, delete locally
        await _db.deleteTransactionByLocalId(transaction.localId);
        await _db.removeFromSyncQueue(item.id);
      } else {
        rethrow;
      }
    }
  }

  /// Handle sync conflict
  Future<void> _handleConflict(
    LocalTransaction transaction,
    SyncQueueItem item,
  ) async {
    debugPrint('SyncQueueService: Conflict detected for ${transaction.serverId}');

    // Fetch server version
    final response = await _api.get('${ApiConfig.transactions}/${transaction.serverId}');

    if (response['success'] == true && response['data'] != null) {
      final serverData = response['data'];
      final serverUpdatedAt = serverData['updatedAt'] != null
          ? DateTime.parse(serverData['updatedAt'])
          : DateTime.now();

      // Last write wins
      if (transaction.updatedAt.isAfter(serverUpdatedAt)) {
        // Local wins - force update
        debugPrint('SyncQueueService: Local wins conflict');
        // Re-queue with force flag (implementation depends on API)
        item.attempts++;
        await _db.updateSyncQueueItem(item);
      } else {
        // Server wins - update local
        debugPrint('SyncQueueService: Server wins conflict');
        transaction.amount = (serverData['amount'] as num).toDouble();
        transaction.category = serverData['category'] ?? transaction.category;
        transaction.description = serverData['description'];
        transaction.transactionDate = serverData['transactionDate'] != null
            ? DateTime.parse(serverData['transactionDate'])
            : transaction.transactionDate;
        transaction.type = serverData['type'] ?? transaction.type;
        transaction.syncStatus = SyncStatus.synced;
        transaction.serverVersion = serverData['version'] ?? transaction.serverVersion;
        await _db.saveTransaction(transaction);

        await _db.removeFromSyncQueue(item.id);
      }
    }
  }

  /// Handle sync error
  Future<void> _handleSyncError(SyncQueueItem item, String error) async {
    item.attempts++;
    item.lastError = error;

    if (item.attempts >= maxRetryAttempts) {
      // Mark transaction as failed
      final transaction = await _db.getTransactionByLocalId(item.localId);
      if (transaction != null) {
        transaction.syncStatus = SyncStatus.failed;
        transaction.syncAttempts = item.attempts;
        transaction.lastSyncError = error;
        transaction.lastSyncAttempt = DateTime.now();
        await _db.saveTransaction(transaction);
      }

      // Remove from queue (will be retried by retry timer)
      await _db.removeFromSyncQueue(item.id);
      debugPrint('SyncQueueService: Item failed after $maxRetryAttempts attempts');
    } else {
      // Update retry count
      await _db.updateSyncQueueItem(item);
      debugPrint('SyncQueueService: Item retry ${item.attempts}/$maxRetryAttempts');
    }
  }

  /// Force sync all pending items
  Future<void> forceSync() async {
    if (!_connectivity.isOnline) {
      _lastError = 'No internet connection';
      notifyListeners();
      return;
    }

    // Reset failed items
    final allTransactions = await _db.isar.localTransactions.where().sortByCreatedAt().findAll();
    final failedTransactions = allTransactions
        .where((t) => t.syncStatus == SyncStatus.failed)
        .toList();

    for (final transaction in failedTransactions) {
      transaction.syncStatus = SyncStatus.pending;
      transaction.syncAttempts = 0;
      await _db.saveTransaction(transaction);

      final queueItem = SyncQueueItem()
        ..entityType = 'transaction'
        ..localId = transaction.localId
        ..operation = SyncOperation.update
        ..payload = ''
        ..createdAt = DateTime.now()
        ..priority = 3;
      await _db.addToSyncQueue(queueItem);
    }

    await _updateCounts();
    await processQueue();
  }

  /// Clear all failed items
  Future<void> clearFailedItems() async {
    final allTransactions = await _db.isar.localTransactions.where().sortByCreatedAt().findAll();
    final failedTransactions = allTransactions
        .where((t) => t.syncStatus == SyncStatus.failed)
        .toList();

    for (final transaction in failedTransactions) {
      await _db.deleteTransactionByLocalId(transaction.localId);
    }

    await _updateCounts();
  }

  /// Dispose the service
  @override
  void dispose() {
    _retryTimer?.cancel();
    _connectivity.removeOnlineCallback(_onConnectivityRestored);
    super.dispose();
  }
}
