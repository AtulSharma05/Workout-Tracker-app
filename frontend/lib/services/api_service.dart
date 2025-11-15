import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'connectivity_service.dart';

/// Main API Service for making HTTP requests to the backend
/// 
/// Features:
/// - Automatic connectivity checking
/// - Request/Response logging
/// - Error handling
/// - Token management
class ApiService {
  late Dio _dio;
  final ConnectivityService _connectivityService;
  String? _authToken;
  
  ApiService(this._connectivityService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        if (ApiConfig.enableLogging) {
          debugPrint('🌐 REQUEST[${options.method}] => ${options.uri}');
          debugPrint('📤 Headers: ${options.headers}');
          debugPrint('📤 Data: ${options.data}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (ApiConfig.enableLogging) {
          debugPrint('✅ RESPONSE[${response.statusCode}] <= ${response.requestOptions.uri}');
          debugPrint('📥 Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (ApiConfig.enableLogging) {
          debugPrint('❌ ERROR[${error.response?.statusCode}] <= ${error.requestOptions.uri}');
          debugPrint('📥 Error: ${error.message}');
          debugPrint('📥 Response: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }
  
  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// Check connectivity before making request
  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
        message: 'No internet connection. Please check your network settings.',
      );
    }
  }
  
  /// GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    await _checkConnectivity();
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    await _checkConnectivity();
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    await _checkConnectivity();
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE request
  Future<Response> delete(String endpoint) async {
    await _checkConnectivity();
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle API errors
  Exception _handleError(DioException error) {
    String errorMessage = 'An unexpected error occurred';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = error.response?.data['message'] ?? 
                      'Server error: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = error.message ?? 
                      'Connection error. Please check if the backend server is running.';
        break;
      default:
        errorMessage = 'Network error: ${error.message}';
    }
    
    return Exception(errorMessage);
  }
}
