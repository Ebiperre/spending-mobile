import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spending_mobile/services/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'],
    );
  }
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  String? _token;
  String? _refreshToken;

  // Initialize - load tokens from storage
  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;

  // Get current token
  String? get token => _token;

  // Set tokens after login
  Future<void> setTokens(String token, String refreshToken) async {
    _token = token;
    _refreshToken = refreshToken;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Build headers
  Map<String, String> _buildHeaders({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Build full URL
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  // Handle response
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Handle 401 - try to refresh token
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        throw ApiException('Token refreshed, retry request', 401);
      }
    }

    // Extract error message - handle various error formats
    String error = 'An error occurred';
    if (body['error'] != null) {
      error = body['error'].toString();
    } else if (body['message'] != null) {
      error = body['message'].toString();
    }

    // If there are validation errors, include them
    if (body['errors'] != null && body['errors'] is List) {
      final errors = body['errors'] as List;
      if (errors.isNotEmpty) {
        error = errors.map((e) => e['msg'] ?? e.toString()).join(', ');
      }
    } else if (body['errors'] != null && body['errors'] is Map) {
      final errors = body['errors'] as Map;
      error = errors.values.join(', ');
    }

    throw ApiException(error, response.statusCode);
  }

  // Try to refresh token
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        _buildUri(ApiConfig.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          await setTokens(
            body['data']['token'],
            body['data']['refreshToken'],
          );
          return true;
        }
      }
    } catch (e) {
      // Refresh failed
    }

    // Clear tokens if refresh failed
    await clearTokens();
    return false;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.get(
        _buildUri(endpoint, queryParams),
        headers: _buildHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.post(
        _buildUri(endpoint),
        headers: _buildHeaders(requiresAuth: requiresAuth),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.put(
        _buildUri(endpoint),
        headers: _buildHeaders(requiresAuth: requiresAuth),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.delete(
        _buildUri(endpoint),
        headers: _buildHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}
