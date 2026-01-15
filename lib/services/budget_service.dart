import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:spending_mobile/models/budget.dart';
import 'package:spending_mobile/models/analytics.dart';
import 'package:spending_mobile/services/api_client.dart';
import 'package:spending_mobile/services/api_config.dart';
import 'package:spending_mobile/services/database_service.dart';
import 'package:spending_mobile/services/connectivity_service.dart';

class BudgetService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();

  DailyBudget? _dailyBudget;
  MonthlyBudget? _monthlyBudget;
  DashboardOverview? _overview;
  List<CategorySpending> _categorySpending = [];
  List<SpendingTrend> _trends = [];
  TrendDirection? _trendDirection;
  WeeklyReport? _weeklyReport;
  bool _isLoading = false;
  String? _error;
  bool _isFromCache = false;

  // Cache keys
  static const String _dailyBudgetKey = 'daily_budget';
  static const String _monthlyBudgetKey = 'monthly_budget';
  static const String _overviewKey = 'overview';
  static const String _categorySpendingKey = 'category_spending';
  static const String _trendsKey = 'trends';
  static const String _weeklyReportKey = 'weekly_report';

  // Cache expiry duration
  static const Duration _cacheExpiry = Duration(hours: 1);

  DailyBudget? get dailyBudget => _dailyBudget;
  MonthlyBudget? get monthlyBudget => _monthlyBudget;
  DashboardOverview? get overview => _overview;
  List<CategorySpending> get categorySpending => _categorySpending;
  List<SpendingTrend> get trends => _trends;
  TrendDirection? get trendDirection => _trendDirection;
  WeeklyReport? get weeklyReport => _weeklyReport;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFromCache => _isFromCache;

  // Fetch daily budget with caching
  Future<void> fetchDailyBudget() async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    // Try cache first
    final cachedData = await _db.getCachedData(_dailyBudgetKey);
    if (cachedData != null) {
      try {
        _dailyBudget = DailyBudget.fromJson(jsonDecode(cachedData));
        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded daily budget from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final response = await _client.get(ApiConfig.dailyBudget);

        if (response['success'] == true && response['data'] != null) {
          _dailyBudget = DailyBudget.fromJson(response['data']);
          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            _dailyBudgetKey,
            jsonEncode(response['data']),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_dailyBudget == null) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_dailyBudget == null) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Fetch monthly budget with caching
  Future<void> fetchMonthlyBudget() async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    // Try cache first
    final cachedData = await _db.getCachedData(_monthlyBudgetKey);
    if (cachedData != null) {
      try {
        _monthlyBudget = MonthlyBudget.fromJson(jsonDecode(cachedData));
        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded monthly budget from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final response = await _client.get(ApiConfig.monthlyBudget);

        if (response['success'] == true && response['data'] != null) {
          _monthlyBudget = MonthlyBudget.fromJson(response['data']);
          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            _monthlyBudgetKey,
            jsonEncode(response['data']),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_monthlyBudget == null) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_monthlyBudget == null) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Calculate/recalculate budget - requires online
  Future<SpendingCycle?> calculateBudget() async {
    if (!_connectivity.isOnline) {
      _setError('Budget calculation requires an internet connection');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(ApiConfig.calculateBudget);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['cycle'] != null) {
          // Invalidate caches since budget changed
          await _invalidateBudgetCache();
          return SpendingCycle.fromJson(data['cycle']);
        }
      }

      return null;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch dashboard overview with caching
  Future<void> fetchOverview() async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    // Try cache first
    final cachedData = await _db.getCachedData(_overviewKey);
    if (cachedData != null) {
      try {
        _overview = DashboardOverview.fromJson(jsonDecode(cachedData));
        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded overview from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final response = await _client.get(ApiConfig.overview);

        if (response['success'] == true && response['data'] != null) {
          _overview = DashboardOverview.fromJson(response['data']);
          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            _overviewKey,
            jsonEncode(response['data']),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_overview == null) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_overview == null) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Fetch spending by category with caching
  Future<void> fetchByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    // Generate cache key based on filters
    final cacheKey = '${_categorySpendingKey}_${startDate?.millisecondsSinceEpoch ?? ''}_${endDate?.millisecondsSinceEpoch ?? ''}';

    // Try cache first
    final cachedData = await _db.getCachedData(cacheKey);
    if (cachedData != null) {
      try {
        final data = jsonDecode(cachedData);
        final categories = data['categories'] as List<dynamic>? ?? [];
        _categorySpending = categories.map((c) => CategorySpending.fromJson(c)).toList();
        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded category spending from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final queryParams = <String, dynamic>{
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        };

        final response = await _client.get(
          ApiConfig.byCategory,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
        );

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          final categories = data['categories'] as List<dynamic>? ?? [];
          _categorySpending = categories.map((c) => CategorySpending.fromJson(c)).toList();
          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            cacheKey,
            jsonEncode(data),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_categorySpending.isEmpty) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_categorySpending.isEmpty) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Fetch spending trends with caching
  Future<void> fetchTrends({String period = 'weekly'}) async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    final cacheKey = '${_trendsKey}_$period';

    // Try cache first
    final cachedData = await _db.getCachedData(cacheKey);
    if (cachedData != null) {
      try {
        final data = jsonDecode(cachedData);
        final trendData = data['data'] as List<dynamic>? ?? [];
        _trends = trendData.map((t) => SpendingTrend.fromJson(t)).toList();

        if (data['trend'] != null) {
          _trendDirection = TrendDirection.fromJson(data['trend']);
        }

        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded trends from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final response = await _client.get(
          ApiConfig.trends,
          queryParams: {'period': period},
        );

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          final trendData = data['data'] as List<dynamic>? ?? [];
          _trends = trendData.map((t) => SpendingTrend.fromJson(t)).toList();

          if (data['trend'] != null) {
            _trendDirection = TrendDirection.fromJson(data['trend']);
          }

          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            cacheKey,
            jsonEncode(data),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_trends.isEmpty) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_trends.isEmpty) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Fetch weekly report with caching
  Future<void> fetchWeeklyReport() async {
    _setLoading(true);
    _clearError();
    _isFromCache = false;

    // Try cache first
    final cachedData = await _db.getCachedData(_weeklyReportKey);
    if (cachedData != null) {
      try {
        _weeklyReport = WeeklyReport.fromJson(jsonDecode(cachedData));
        _isFromCache = true;
        notifyListeners();
        debugPrint('BudgetService: Loaded weekly report from cache');
      } catch (e) {
        debugPrint('BudgetService: Error parsing cached data: $e');
      }
    }

    // Fetch from server if online
    if (_connectivity.isOnline) {
      try {
        final response = await _client.get(ApiConfig.weeklyReport);

        if (response['success'] == true && response['data'] != null) {
          _weeklyReport = WeeklyReport.fromJson(response['data']);
          _isFromCache = false;

          // Update cache
          await _db.setCachedData(
            _weeklyReportKey,
            jsonEncode(response['data']),
            expiry: _cacheExpiry,
          );

          notifyListeners();
        }
      } on ApiException catch (e) {
        if (_weeklyReport == null) {
          _setError(e.message);
        }
        debugPrint('BudgetService: API error (using cache): ${e.message}');
      }
    } else if (_weeklyReport == null) {
      _setError('No cached data available');
    }

    _setLoading(false);
  }

  // Fetch monthly report - requires online (no caching for now)
  Future<WeeklyReport?> fetchMonthlyReport({int? month, int? year}) async {
    if (!_connectivity.isOnline) {
      _setError('Monthly report requires an internet connection');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final now = DateTime.now();
      final queryParams = <String, dynamic>{
        'month': month ?? now.month,
        'year': year ?? now.year,
      };

      final response = await _client.get(
        ApiConfig.monthlyReport,
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        return WeeklyReport.fromJson(response['data']);
      }

      return null;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all budget data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchDailyBudget(),
      fetchMonthlyBudget(),
      fetchOverview(),
    ]);
  }

  // Invalidate budget-related caches
  Future<void> _invalidateBudgetCache() async {
    // Clear expired cache entries
    await _db.clearExpiredCache();
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _db.clearExpiredCache();
    debugPrint('BudgetService: Cache cleared');
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

  void clearData() {
    _dailyBudget = null;
    _monthlyBudget = null;
    _overview = null;
    _categorySpending = [];
    _trends = [];
    _trendDirection = null;
    _weeklyReport = null;
    _isFromCache = false;
    notifyListeners();
  }
}
