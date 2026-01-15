import 'package:flutter/foundation.dart';
import 'package:spending_mobile/models/user.dart';
import 'package:spending_mobile/services/api_client.dart';
import 'package:spending_mobile/services/api_config.dart';

class SettingsService extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  FinancialProfile? _financialProfile;
  SalarySettings? _salarySettings;
  PaydaySettings? _paydaySettings;
  String _currency = 'NGN';
  String _currencySymbol = '₦';
  String _language = 'mix';
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  String? _error;

  FinancialProfile? get financialProfile => _financialProfile;
  SalarySettings? get salarySettings => _salarySettings;
  PaydaySettings? get paydaySettings => _paydaySettings;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  String get language => _language;
  NotificationSettings? get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch financial profile
  Future<void> fetchFinancialProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.get(ApiConfig.financialProfile);

      if (response['success'] == true && response['data'] != null) {
        _financialProfile = FinancialProfile.fromJson(response['data']);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // Create/update financial profile
  Future<bool> saveFinancialProfile({
    required double monthlyIncome,
    required int salaryDay,
    double rent = 0,
    double transport = 0,
    double bills = 0,
    double savingsTarget = 0,
    double otherFixed = 0,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.financialProfile,
        body: {
          'monthly_income': monthlyIncome,
          'salary_day': salaryDay,
          'rent': rent,
          'transport': transport,
          'bills': bills,
          'savings_target': savingsTarget,
          'other_fixed': otherFixed,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        _financialProfile = FinancialProfile.fromJson(response['data']);
        notifyListeners();
        return true;
      }

      _setError(response['error'] ?? 'Failed to save financial profile');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch salary settings
  Future<void> fetchSalarySettings() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.get(ApiConfig.salary);

      if (response['success'] == true && response['data'] != null) {
        _salarySettings = SalarySettings.fromJson(response['data']);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // Update salary settings
  Future<bool> updateSalarySettings({
    required double amount,
    required String frequency,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.salary,
        body: {
          'amount': amount,
          'frequency': frequency,
        },
      );

      if (response['success'] == true) {
        await fetchSalarySettings();
        return true;
      }

      _setError(response['error'] ?? 'Failed to update salary');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payday settings
  Future<void> fetchPaydaySettings() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.get(ApiConfig.payday);

      if (response['success'] == true && response['data'] != null) {
        _paydaySettings = PaydaySettings.fromJson(response['data']);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // Update payday settings
  Future<bool> updatePaydaySettings({
    required int day,
    required String type,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.payday,
        body: {
          'day': day,
          'type': type,
        },
      );

      if (response['success'] == true) {
        await fetchPaydaySettings();
        return true;
      }

      _setError(response['error'] ?? 'Failed to update payday');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch currency settings
  Future<void> fetchCurrencySettings() async {
    try {
      final response = await _client.get(ApiConfig.currency);

      if (response['success'] == true && response['data'] != null) {
        _currency = response['data']['currency'] ?? 'NGN';
        _currencySymbol = response['data']['symbol'] ?? '₦';
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    }
  }

  // Update currency
  Future<bool> updateCurrency(String currency) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.currency,
        body: {'currency': currency},
      );

      if (response['success'] == true) {
        await fetchCurrencySettings();
        return true;
      }

      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch language settings
  Future<void> fetchLanguageSettings() async {
    try {
      final response = await _client.get(ApiConfig.language);

      if (response['success'] == true && response['data'] != null) {
        _language = response['data']['language'] ?? 'mix';
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    }
  }

  // Update language
  Future<bool> updateLanguage(String language) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.language,
        body: {'language': language},
      );

      if (response['success'] == true) {
        _language = language;
        notifyListeners();
        return true;
      }

      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch notification settings
  Future<void> fetchNotificationSettings() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.get(ApiConfig.notificationSettings);

      if (response['success'] == true && response['data'] != null) {
        _notificationSettings = NotificationSettings.fromJson(response['data']);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings({
    bool? morningBriefing,
    String? morningBriefingTime,
    bool? eveningCheckin,
    String? eveningCheckinTime,
    bool? budgetAlerts,
    bool? achievementNotifications,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.notificationSettings,
        body: {
          if (morningBriefing != null) 'morning_briefing': morningBriefing,
          if (morningBriefingTime != null) 'morning_briefing_time': morningBriefingTime,
          if (eveningCheckin != null) 'evening_checkin': eveningCheckin,
          if (eveningCheckinTime != null) 'evening_checkin_time': eveningCheckinTime,
          if (budgetAlerts != null) 'budget_alerts': budgetAlerts,
          if (achievementNotifications != null) 'achievement_notifications': achievementNotifications,
        },
      );

      if (response['success'] == true) {
        await fetchNotificationSettings();
        return true;
      }

      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register device for push notifications
  Future<bool> registerDevice({
    required String deviceToken,
    required String platform,
    String? deviceName,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.registerDevice,
        body: {
          'device_token': deviceToken,
          'platform': platform,
          if (deviceName != null) 'device_name': deviceName,
        },
      );

      return response['success'] == true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // Refresh all settings
  Future<void> refreshAll() async {
    await Future.wait([
      fetchFinancialProfile(),
      fetchCurrencySettings(),
      fetchLanguageSettings(),
      fetchNotificationSettings(),
    ]);
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
    _financialProfile = null;
    _salarySettings = null;
    _paydaySettings = null;
    _notificationSettings = null;
    notifyListeners();
  }
}

class SalarySettings {
  final double monthlyIncome;
  final int salaryDay;
  final double spendableAmount;

  SalarySettings({
    required this.monthlyIncome,
    required this.salaryDay,
    required this.spendableAmount,
  });

  factory SalarySettings.fromJson(Map<String, dynamic> json) {
    return SalarySettings(
      monthlyIncome: (json['monthly_income'] ?? json['monthlyIncome'] ?? 0).toDouble(),
      salaryDay: json['salary_day'] ?? json['salaryDay'] ?? 25,
      spendableAmount: (json['spendable_amount'] ?? json['spendableAmount'] ?? 0).toDouble(),
    );
  }
}

class PaydaySettings {
  final int day;
  final String type;

  PaydaySettings({
    required this.day,
    required this.type,
  });

  factory PaydaySettings.fromJson(Map<String, dynamic> json) {
    return PaydaySettings(
      day: json['day'] ?? 25,
      type: json['type'] ?? 'fixed',
    );
  }
}

class NotificationSettings {
  final bool morningBriefing;
  final String morningBriefingTime;
  final bool eveningCheckin;
  final String eveningCheckinTime;
  final bool budgetAlerts;
  final bool achievementNotifications;

  NotificationSettings({
    this.morningBriefing = true,
    this.morningBriefingTime = '08:00',
    this.eveningCheckin = true,
    this.eveningCheckinTime = '20:00',
    this.budgetAlerts = true,
    this.achievementNotifications = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      morningBriefing: json['morning_briefing'] ?? json['morningBriefing'] ?? true,
      morningBriefingTime: json['morning_briefing_time'] ?? json['morningBriefingTime'] ?? '08:00',
      eveningCheckin: json['evening_checkin'] ?? json['eveningCheckin'] ?? true,
      eveningCheckinTime: json['evening_checkin_time'] ?? json['eveningCheckinTime'] ?? '20:00',
      budgetAlerts: json['budget_alerts'] ?? json['budgetAlerts'] ?? true,
      achievementNotifications: json['achievement_notifications'] ?? json['achievementNotifications'] ?? true,
    );
  }
}
