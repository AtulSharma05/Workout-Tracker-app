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
        if (userData != null) {
          await _saveUser(userData);
        }
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
        if (userData != null) {
          await _saveUser(userData);
        }
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
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'user_email');
    await _secureStorage.delete(key: 'user_username');
    await _secureStorage.delete(key: 'user_fullName');
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
  
  /// Save user data
  Future<void> _saveUser(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: 'user_id', value: userData['_id'] ?? userData['id']);
    await _secureStorage.write(key: 'user_email', value: userData['email']);
    if (userData['username'] != null) {
      await _secureStorage.write(key: 'user_username', value: userData['username']);
    }
    if (userData['fullName'] != null) {
      await _secureStorage.write(key: 'user_fullName', value: userData['fullName']);
    }
  }
  
  /// Get current user data
  Future<User?> getCurrentUser() async {
    final id = await _secureStorage.read(key: 'user_id');
    if (id == null) return null;
    
    final email = await _secureStorage.read(key: 'user_email');
    final username = await _secureStorage.read(key: 'user_username');
    final fullName = await _secureStorage.read(key: 'user_fullName');
    
    if (email == null) return null;
    
    return User(
      id: id,
      email: email,
      username: username,
      fullName: fullName,
      createdAt: DateTime.now(),
    );
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
