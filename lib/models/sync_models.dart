import 'package:isar/isar.dart';

part 'sync_models.g.dart';

/// Sync status for tracking local changes
enum SyncStatus {
  synced,   // Data matches server
  pending,  // Created/modified locally, not yet synced
  failed,   // Sync attempted but failed
  deleted,  // Marked for deletion, pending sync
}

/// Sync operation types for the queue
enum SyncOperation {
  create,
  update,
  delete,
}

/// Local transaction with sync metadata
@collection
class LocalTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  String? serverId; // Server-side ID (null for local-only)

  @Index(unique: true)
  late String localId; // UUID for local identification

  late double amount;
  late String category;
  String? description;

  @Index()
  late DateTime transactionDate;

  late String type; // 'income' or 'expense'
  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  @enumerated
  late SyncStatus syncStatus;

  int syncAttempts = 0;
  String? lastSyncError;
  DateTime? lastSyncAttempt;

  /// Server version for conflict detection
  int serverVersion = 0;
  int localVersion = 1;

  /// Check if this is an income transaction
  bool get isIncome => type == 'income';

  /// Check if this is an expense transaction
  bool get isExpense => type == 'expense';
}

/// Local recurring transaction with sync metadata
@collection
class LocalRecurringTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  String? serverId;

  @Index(unique: true)
  late String localId;

  late double amount;
  late String category;
  String? description;
  late String frequency; // 'daily', 'weekly', 'biweekly', 'monthly'
  int? dayOfMonth;
  int? dayOfWeek;
  late bool isActive;
  DateTime? nextOccurrence;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  @enumerated
  late SyncStatus syncStatus;

  int syncAttempts = 0;
  String? lastSyncError;
}

/// Cache for budget data
@collection
class LocalBudgetCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String cacheKey; // 'daily_budget', 'monthly_budget', 'overview', etc.

  late String jsonData; // Serialized budget data
  late DateTime cachedAt;
  late DateTime expiresAt;

  /// Check if cache is still valid
  bool get isValid => expiresAt.isAfter(DateTime.now());

  /// Check if cache is expired
  bool get isExpired => !isValid;
}

/// Sync queue item for pending operations
@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String entityType; // 'transaction', 'recurring'

  late String localId;

  @Index()
  @enumerated
  late SyncOperation operation;

  late String payload; // JSON payload

  @Index()
  late DateTime createdAt;

  int attempts = 0;
  int maxAttempts = 3;
  String? lastError;
  DateTime? lastAttempt;

  @Index()
  late int priority; // Lower = higher priority (1 = create, 2 = delete, 3 = update)

  /// Check if item can be retried
  bool get canRetry => attempts < maxAttempts;

  /// Check if item has failed permanently
  bool get hasFailed => attempts >= maxAttempts;
}

/// Metadata for sync state
@collection
class SyncMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String key;

  late String value;
  late DateTime updatedAt;
}
