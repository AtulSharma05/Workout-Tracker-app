import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authentication Service
/// Handles user login, registration, and token management
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthService(this._apiService);
  
  /// Expose apiService for custom calls
  ApiService get apiService => _apiService;
  
  /// Register new user with full profile
  Future<Map<String, dynamic>> registerFull({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.authEndpoint}/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        },
      );
      
      // Backend returns: { status, message, data: { user, tokens: { accessToken, refreshToken } } }
      final data = response.data['data'];
      final token = data['tokens']['accessToken'];
      final userData = data['user'];
      
      if (token != null) {
        await _saveToken(token);
        _apiService.setAuthToken(token);
      }
      
      return {
        'success': true,
        'user': userData != null ? User.fromJson(userData) : null,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Register new user (basic)
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.authEndpoint}/register',
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
      );
      
      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
        _apiService.setAuthToken(response.data['token']);
      }
      
      return {
        'success': true,
        'user': User.fromJson(response.data['user']),
        'token': response.data['token'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Backend returns: { status, message, data: { user, tokens: { accessToken, refreshToken } } }
      final data = response.data['data'];
      final token = data['tokens']['accessToken'];
      final userData = data['user'];
      
      if (token != null) {
        await _saveToken(token);
        _apiService.setAuthToken(token);
      }
      
      return {
        'success': true,
        'user': userData != null ? User.fromJson(userData) : null,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    _apiService.clearAuthToken();
  }
  
  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
  
  /// Save token securely
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
