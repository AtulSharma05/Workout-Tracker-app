import 'dart:io';

/// API Configuration for different environments
/// 
/// CRITICAL: This handles the connectivity issue between Flutter and backend
/// - Uses 10.0.2.2 for Android emulator (maps to host's localhost)
/// - Uses localhost for iOS simulator
/// - Uses actual network IP for physical devices
class ApiConfig {
  // CHANGE THIS to your computer's local IP address when testing on physical devices
  // Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String _networkIP = '192.168.1.10'; // Your computer's IP
  
  static const String _port = '3000';
  static const String _apiVersion = 'v1';
  
  /// Get the appropriate base URL based on the platform and environment
  static String get baseUrl {
    // For physical devices, use the network IP
    // For emulators/simulators, use platform-specific localhost mapping
    
    // Note: Change _useEmulator to false when testing on physical device
    const bool _useEmulator = false; // SET TO false FOR PHYSICAL DEVICE
    
    if (Platform.isAndroid && _useEmulator) {
      // Android emulator uses 10.0.2.2 to access host's localhost
      return 'http://10.0.2.2:$_port/api/$_apiVersion';
    } else if (Platform.isIOS && _useEmulator) {
      // iOS simulator can use localhost directly
      return 'http://localhost:$_port/api/$_apiVersion';
    } else {
      // For physical devices or other platforms
      return 'http://$_networkIP:$_port/api/$_apiVersion';
    }
  }
  
  /// Get network-based URL (for physical devices)
  static String get networkUrl => 'http://$_networkIP:$_port/api/$_apiVersion';
  
  /// Get localhost URL (for testing)
  static String get localhostUrl => 'http://localhost:$_port/api/$_apiVersion';
  
  /// API endpoints
  static const String authEndpoint = '/auth';
  static const String workoutEndpoint = '/workouts';
  static const String workoutStatsEndpoint = '/workouts/stats';
  
  // AI Workout Planner endpoints
  static const String workoutPlansGenerateEndpoint = '/workout-plans/generate';
  static const String workoutPlansRecommendEndpoint = '/workout-plans/recommend-exercises';
  static const String workoutPlansPredictEndpoint = '/workout-plans/predict-sets';
  static const String workoutPlansStatusEndpoint = '/workout-plans/status';
  
  // Exercise database endpoints
  static const String exercisesSearchEndpoint = '/exercises/search';
  static const String exercisesEndpoint = '/exercises';
  
  // Pose analysis endpoints
  static const String poseHealthEndpoint = '/pose/health';
  static const String poseStartSessionEndpoint = '/pose/start-session';
  static const String poseSessionSummaryEndpoint = '/pose/session-summary';
  static const String poseResetEndpoint = '/pose/reset';
  static const String poseSearchEndpoint = '/pose/search';
  
  /// Get pose analysis WebSocket URL
  static String get poseWebSocketUrl {
    // Note: Change _useEmulator to false when testing on physical device
    const bool _useEmulator = false; // SET TO false FOR PHYSICAL DEVICE
    
    String wsBaseUrl;
    if (Platform.isAndroid && _useEmulator) {
      wsBaseUrl = 'ws://10.0.2.2:8001';
    } else if (Platform.isIOS && _useEmulator) {
      wsBaseUrl = 'ws://localhost:8001';
    } else {
      wsBaseUrl = 'ws://$_networkIP:8001';
    }
    return '$wsBaseUrl/ws/pose-analysis';
  }
  
  /// Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  /// Enable/disable logging
  static const bool enableLogging = true;
}
