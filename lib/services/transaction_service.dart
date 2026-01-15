import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spending_mobile/models/transaction.dart';
import 'package:spending_mobile/models/user.dart';
import 'package:spending_mobile/models/sync_models.dart';
import 'package:spending_mobile/services/api_client.dart';
import 'package:spending_mobile/services/api_config.dart';
import 'package:spending_mobile/services/database_service.dart';
import 'package:spending_mobile/services/connectivity_service.dart';
import 'package:spending_mobile/services/sync_queue_service.dart';
import 'package:spending_mobile/services/conflict_resolver.dart';

class TransactionService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncQueueService _syncQueue = SyncQueueService();
  final ConflictResolver _conflictResolver = ConflictResolver();
  final Uuid _uuid = const Uuid();

  List<Transaction> _transactions = [];
  List<RecurringTransaction> _recurringTransactions = [];
  TransactionPagination? _pagination;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Transaction> get transactions => _transactions;
  List<RecurringTransaction> get recurringTransactions => _recurringTransactions;
  TransactionPagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the service and load local data
  Future<void> init() async {
    if (_isInitialized) return;

    // Load from local database first (instant UI)
    await _loadFromLocalDatabase();

    // Sync with server if online
    if (_connectivity.isOnline) {
      await _syncWithServer();
    }

    _isInitialized = true;
  }

  /// Load transactions from local database
  Future<void> _loadFromLocalDatabase() async {
    try {
      final localTransactions = await _db.getAllTransactions(limit: 50);
      _transactions = localTransactions.map(_localToTransaction).toList();
      notifyListeners();
      debugPrint('TransactionService: Loaded ${_transactions.length} transactions from local DB');
    } catch (e) {
      debugPrint('TransactionService: Error loading from local DB: $e');
    }
  }

  /// Convert LocalTransaction to Transaction model
  Transaction _localToTransaction(LocalTransaction local) {
    return Transaction(
      id: local.serverId ?? local.localId,
      amount: local.amount,
      category: local.category,
      description: local.description,
      transactionDate: local.transactionDate,
      type: local.type,
      createdAt: local.createdAt,
      // Add sync status info for UI
      syncStatus: local.syncStatus.name,
    );
  }

  /// Sync with server
  Future<void> _syncWithServer() async {
    if (!_connectivity.isOnline) return;

    try {
      // Fetch from server
      final response = await _client.get(
        ApiConfig.transactions,
        queryParams: {'limit': 100},
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>;

        // Merge server data with local
        final serverTransactions = data.map((t) => t as Map<String, dynamic>).toList();
        final result = await _conflictResolver.mergeServerTransactions(serverTransactions);
        debugPrint('TransactionService: Merge result - $result');

        // Reload from local database
        await _loadFromLocalDatabase();
      }
    } catch (e) {
      debugPrint('TransactionService: Error syncing with server: $e');
    }
  }

  // Fetch transactions with optional filters
  Future<void> fetchTransactions({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? type,
    String? search,
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    // Always load from local first
    try {
      final localTransactions = await _db.getAllTransactions(
        limit: limit,
        offset: (page - 1) * limit,
        startDate: startDate,
        endDate: endDate,
        category: category,
        type: type,
      );

      if (refresh || page == 1) {
        _transactions = localTransactions.map(_localToTransaction).toList();
      } else {
        _transactions.addAll(localTransactions.map(_localToTransaction));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('TransactionService: Error loading local transactions: $e');
    }

    // Then try to fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final queryParams = <String, dynamic>{
          'page': page,
          'limit': limit,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (category != null) 'category': category,
          if (type != null) 'type': type,
          if (search != null && search.isNotEmpty) 'search': search,
        };

        final response = await _client.get(
          ApiConfig.transactions,
          queryParams: queryParams,
        );

        if (response['success'] == true) {
          final data = response['data'] as List<dynamic>;

          // Merge and reload
          final serverTransactions = data.map((t) => t as Map<String, dynamic>).toList();
          await _conflictResolver.mergeServerTransactions(serverTransactions);

          // Reload from local
          final updatedLocal = await _db.getAllTransactions(
            limit: limit,
            offset: (page - 1) * limit,
            startDate: startDate,
            endDate: endDate,
            category: category,
            type: type,
          );

          if (refresh || page == 1) {
            _transactions = updatedLocal.map(_localToTransaction).toList();
          } else {
            _transactions = updatedLocal.map(_localToTransaction).toList();
          }

          if (response['pagination'] != null) {
            _pagination = TransactionPagination.fromJson(response['pagination']);
          }

          notifyListeners();
        }
      } on ApiException catch (e) {
        // Don't set error for network issues when we have local data
        if (_transactions.isEmpty) {
          _setError(e.message);
        }
        debugPrint('TransactionService: API error (using local data): ${e.message}');
      }
    }

    _setLoading(false);
  }

  // Create transaction (offline-first)
  Future<Transaction?> createTransaction({
    required double amount,
    required String category,
    String? description,
    DateTime? date,
    String type = 'expense',
  }) async {
    _setLoading(true);
    _clearError();

    final now = DateTime.now();
    final transactionDate = date ?? now;
    final localId = _uuid.v4();

    // Create local transaction first
    final localTransaction = LocalTransaction()
      ..localId = localId
      ..amount = amount
      ..category = category
      ..description = description
      ..transactionDate = transactionDate
      ..type = type
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    try {
      // Save to local database
      await _db.saveTransaction(localTransaction);

      // Add to in-memory list
      final transaction = _localToTransaction(localTransaction);
      _transactions.insert(0, transaction);
      notifyListeners();

      // Queue for sync
      await _syncQueue.queueTransaction(localTransaction, SyncOperation.create);

      _setLoading(false);
      return transaction;
    } catch (e) {
      _setError('Failed to create transaction: $e');
      _setLoading(false);
      return null;
    }
  }

  // Update transaction (offline-first)
  Future<bool> updateTransaction(
    String id, {
    double? amount,
    String? category,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Find local transaction
      LocalTransaction? localTransaction;

      // Try to find by server ID first
      localTransaction = await _db.getTransactionByServerId(id);

      // If not found, try local ID
      localTransaction ??= await _db.getTransactionByLocalId(id);

      if (localTransaction == null) {
        _setError('Transaction not found');
        _setLoading(false);
        return false;
      }

      // Update fields
      if (amount != null) localTransaction.amount = amount;
      if (category != null) localTransaction.category = category;
      if (description != null) localTransaction.description = description;
      localTransaction.updatedAt = DateTime.now();
      localTransaction.localVersion++;

      // Only set to pending if it was synced before
      if (localTransaction.syncStatus == SyncStatus.synced) {
        localTransaction.syncStatus = SyncStatus.pending;
      }

      // Save locally
      await _db.saveTransaction(localTransaction);

      // Update in-memory list
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = _localToTransaction(localTransaction);
        notifyListeners();
      }

      // Queue for sync
      await _syncQueue.queueTransaction(localTransaction, SyncOperation.update);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete transaction (offline-first)
  Future<bool> deleteTransaction(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Find local transaction
      LocalTransaction? localTransaction;
      localTransaction = await _db.getTransactionByServerId(id);
      localTransaction ??= await _db.getTransactionByLocalId(id);

      if (localTransaction == null) {
        _setError('Transaction not found');
        _setLoading(false);
        return false;
      }

      if (localTransaction.serverId != null) {
        // Has server ID, mark for deletion and queue
        localTransaction.syncStatus = SyncStatus.deleted;
        localTransaction.updatedAt = DateTime.now();
        await _db.saveTransaction(localTransaction);

        // Queue for sync
        await _syncQueue.queueTransaction(localTransaction, SyncOperation.delete);
      } else {
        // Never synced, just delete locally
        await _db.deleteTransactionByLocalId(localTransaction.localId);
      }

      // Remove from in-memory list
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      _setLoading(false);
      return false;
    }
  }

  // Quick add (daily check-in) - requires online
  Future<QuickAddResult?> quickAdd({
    required String status, // below, exact, above
    double? amount,
    String category = 'general',
    String? notes,
  }) async {
    if (!_connectivity.isOnline) {
      _setError('Quick add requires an internet connection');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        '${ApiConfig.transactions}/quick-add',
        body: {
          'status': status,
          if (amount != null) 'amount': amount,
          'category': category,
          if (notes != null) 'notes': notes,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        return QuickAddResult(
          checkin: data['checkin'],
          streak: data['streak'] != null ? Streak.fromJson(data['streak']) : null,
        );
      }

      _setError(response['error'] ?? 'Failed to record check-in');
      return null;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch recurring transactions
  Future<void> fetchRecurringTransactions() async {
    _setLoading(true);
    _clearError();

    if (!_connectivity.isOnline) {
      // TODO: Load from local cache
      _setLoading(false);
      return;
    }

    try {
      final response = await _client.get(ApiConfig.recurring);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final recurring = data['recurring'] as List<dynamic>? ?? [];
        _recurringTransactions = recurring.map((r) => RecurringTransaction.fromJson(r)).toList();
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // Create recurring transaction
  Future<RecurringTransaction?> createRecurring({
    required double amount,
    required String category,
    String? description,
    required String frequency,
    int? dayOfMonth,
  }) async {
    if (!_connectivity.isOnline) {
      _setError('Creating recurring transactions requires an internet connection');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.recurring,
        body: {
          'amount': amount,
          'category': category,
          if (description != null) 'description': description,
          'frequency': frequency,
          if (dayOfMonth != null) 'day_of_month': dayOfMonth,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final recurring = RecurringTransaction.fromJson(response['data']);
        _recurringTransactions.add(recurring);
        notifyListeners();
        return recurring;
      }

      _setError(response['error'] ?? 'Failed to create recurring transaction');
      return null;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle recurring transaction
  Future<bool> toggleRecurring(String id) async {
    if (!_connectivity.isOnline) {
      _setError('This action requires an internet connection');
      return false;
    }

    try {
      final response = await _client.put('${ApiConfig.recurring}/$id/toggle');

      if (response['success'] == true) {
        final index = _recurringTransactions.indexWhere((r) => r.id == id);
        if (index != -1) {
          // Refresh the list to get updated state
          await fetchRecurringTransactions();
        }
        return true;
      }

      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // Delete recurring transaction
  Future<bool> deleteRecurring(String id) async {
    if (!_connectivity.isOnline) {
      _setError('This action requires an internet connection');
      return false;
    }

    try {
      final response = await _client.delete('${ApiConfig.recurring}/$id');

      if (response['success'] == true) {
        _recurringTransactions.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }

      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  /// Force refresh from server
  Future<void> refreshFromServer() async {
    if (!_connectivity.isOnline) {
      _setError('No internet connection');
      return;
    }

    await _syncWithServer();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearTransactions() {
    _transactions = [];
    _pagination = null;
    notifyListeners();
  }
}

class QuickAddResult {
  final dynamic checkin;
  final Streak? streak;

  QuickAddResult({this.checkin, this.streak});
}
