import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sync_models.dart';

/// Service for managing the local Isar database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;
  bool _isInitialized = false;

  /// Get the Isar instance
  Isar get isar {
    if (_isar == null) {
      throw StateError('DatabaseService not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Check if database is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the database
  Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        LocalTransactionSchema,
        LocalRecurringTransactionSchema,
        LocalBudgetCacheSchema,
        SyncQueueItemSchema,
        SyncMetadataSchema,
      ],
      directory: dir.path,
      name: 'spending_mobile',
    );

    _isInitialized = true;
  }

  /// Clear all data from the database
  Future<void> clearAll() async {
    await _isar?.writeTxn(() async {
      await _isar!.clear();
    });
  }

  /// Close the database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _isInitialized = false;
  }

  // ============================================
  // Transaction helpers
  // ============================================

  /// Get all local transactions
  Future<List<LocalTransaction>> getAllTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? type,
  }) async {
    // Get all transactions and filter manually to avoid query builder complexity
    final allTransactions = await isar.localTransactions
        .where()
        .sortByTransactionDateDesc()
        .findAll();

    // Filter in memory
    var filtered = allTransactions.where((t) => t.syncStatus != SyncStatus.deleted);

    if (startDate != null) {
      filtered = filtered.where((t) =>
          t.transactionDate.isAfter(startDate) ||
          t.transactionDate.isAtSameMomentAs(startDate));
    }
    if (endDate != null) {
      filtered = filtered.where((t) =>
          t.transactionDate.isBefore(endDate) ||
          t.transactionDate.isAtSameMomentAs(endDate));
    }
    if (category != null) {
      filtered = filtered.where((t) => t.category == category);
    }
    if (type != null) {
      filtered = filtered.where((t) => t.type == type);
    }

    // Apply pagination
    var result = filtered.toList();
    if (offset != null && offset > 0) {
      result = result.skip(offset).toList();
    }
    if (limit != null) {
      result = result.take(limit).toList();
    }

    return result;
  }

  /// Get transaction by local ID
  Future<LocalTransaction?> getTransactionByLocalId(String localId) async {
    return await isar.localTransactions
        .where()
        .localIdEqualTo(localId)
        .findFirst();
  }

  /// Get transaction by server ID
  Future<LocalTransaction?> getTransactionByServerId(String serverId) async {
    return await isar.localTransactions
        .where()
        .serverIdEqualTo(serverId)
        .findFirst();
  }

  /// Save a transaction
  Future<int> saveTransaction(LocalTransaction transaction) async {
    return await isar.writeTxn(() async {
      return await isar.localTransactions.put(transaction);
    });
  }

  /// Delete a transaction by local ID
  Future<bool> deleteTransactionByLocalId(String localId) async {
    return await isar.writeTxn(() async {
      final count = await isar.localTransactions
          .where()
          .localIdEqualTo(localId)
          .deleteAll();
      return count > 0;
    });
  }

  /// Get pending transactions count
  Future<int> getPendingTransactionsCount() async {
    return await isar.localTransactions
        .where()
        .syncStatusEqualTo(SyncStatus.pending)
        .count();
  }

  /// Get failed transactions count
  Future<int> getFailedTransactionsCount() async {
    return await isar.localTransactions
        .where()
        .syncStatusEqualTo(SyncStatus.failed)
        .count();
  }

  // ============================================
  // Cache helpers
  // ============================================

  /// Get cached data by key
  Future<String?> getCachedData(String key) async {
    final cache = await isar.localBudgetCaches
        .where()
        .cacheKeyEqualTo(key)
        .findFirst();

    if (cache != null && cache.isValid) {
      return cache.jsonData;
    }
    return null;
  }

  /// Save data to cache
  Future<void> setCachedData(
    String key,
    String data, {
    Duration expiry = const Duration(hours: 1),
  }) async {
    final now = DateTime.now();
    final cache = LocalBudgetCache()
      ..cacheKey = key
      ..jsonData = data
      ..cachedAt = now
      ..expiresAt = now.add(expiry);

    await isar.writeTxn(() async {
      // Delete old cache entry if exists
      await isar.localBudgetCaches.where().cacheKeyEqualTo(key).deleteAll();
      await isar.localBudgetCaches.put(cache);
    });
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    await isar.writeTxn(() async {
      final expired = await isar.localBudgetCaches
          .where()
          .filter()
          .expiresAtLessThan(now)
          .findAll();
      for (final cache in expired) {
        await isar.localBudgetCaches.delete(cache.id);
      }
    });
  }

  // ============================================
  // Sync queue helpers
  // ============================================

  /// Add item to sync queue
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    await isar.writeTxn(() async {
      await isar.syncQueueItems.put(item);
    });
  }

  /// Get all pending sync items
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    return await isar.syncQueueItems
        .where()
        .sortByPriority()
        .thenByCreatedAt()
        .findAll();
  }

  /// Get sync queue count
  Future<int> getSyncQueueCount() async {
    return await isar.syncQueueItems.count();
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(int id) async {
    await isar.writeTxn(() async {
      await isar.syncQueueItems.delete(id);
    });
  }

  /// Update sync queue item
  Future<void> updateSyncQueueItem(SyncQueueItem item) async {
    await isar.writeTxn(() async {
      await isar.syncQueueItems.put(item);
    });
  }

  // ============================================
  // Metadata helpers
  // ============================================

  /// Get metadata value
  Future<String?> getMetadata(String key) async {
    final metadata = await isar.syncMetadatas
        .where()
        .keyEqualTo(key)
        .findFirst();
    return metadata?.value;
  }

  /// Set metadata value
  Future<void> setMetadata(String key, String value) async {
    final metadata = SyncMetadata()
      ..key = key
      ..value = value
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.syncMetadatas.where().keyEqualTo(key).deleteAll();
      await isar.syncMetadatas.put(metadata);
    });
  }
}
