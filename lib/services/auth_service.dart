import 'package:flutter/foundation.dart';
import 'package:spending_mobile/models/user.dart';
import 'package:spending_mobile/services/api_client.dart';
import 'package:spending_mobile/services/api_config.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  User? _currentUser;
  FinancialProfile? _financialProfile;
  Streak? _streak;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  FinancialProfile? get financialProfile => _financialProfile;
  Streak? get streak => _streak;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _client.isAuthenticated && _currentUser != null;

  // Initialize - check if user is logged in
  Future<bool> init() async {
    await _client.init();
    if (_client.isAuthenticated) {
      try {
        await fetchCurrentUser();
        return true;
      } catch (e) {
        // Token invalid, clear it
        await _client.clearTokens();
        return false;
      }
    }
    return false;
  }

  // Register new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? gender,
    String? ageRange,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.register,
        body: {
          'full_name': fullName,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          if (gender != null) 'gender': gender,
          if (ageRange != null) 'age_range': ageRange,
        },
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        await _client.setTokens(data['token'], data['refreshToken']);
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
        return true;
      }

      _setError(response['error'] ?? 'Registration failed');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        await _client.setTokens(data['token'], data['refreshToken']);
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
        return true;
      }

      _setError(response['error'] ?? 'Login failed');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.logout);
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await _client.clearTokens();
      _currentUser = null;
      _financialProfile = null;
      _streak = null;
      notifyListeners();
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.forgotPassword,
        body: {'email': email},
        requiresAuth: false,
      );

      return response['success'] == true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.post(
        ApiConfig.resetPassword,
        body: {
          'token': token,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      return response['success'] == true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch current user profile
  Future<void> fetchCurrentUser() async {
    try {
      final response = await _client.get(ApiConfig.me);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _currentUser = User.fromJson(data['user']);

        if (data['financialProfile'] != null) {
          _financialProfile = FinancialProfile.fromJson(data['financialProfile']);
        }

        if (data['streak'] != null) {
          _streak = Streak.fromJson(data['streak']);
        }

        notifyListeners();
      }
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? languagePreference,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.me,
        body: {
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (languagePreference != null) 'language_preference': languagePreference,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        _currentUser = User.fromJson(response['data']['user']);
        notifyListeners();
        return true;
      }

      _setError(response['error'] ?? 'Update failed');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.put(
        ApiConfig.changePassword,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response['success'] == true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _client.delete(ApiConfig.me);

      if (response['success'] == true) {
        await _client.clearTokens();
        _currentUser = null;
        _financialProfile = null;
        _streak = null;
        notifyListeners();
        return true;
      }

      _setError(response['error'] ?? 'Delete failed');
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
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
}
