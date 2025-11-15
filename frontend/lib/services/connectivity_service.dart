import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Service to check network connectivity before making API calls
/// This prevents silent fallback to Hive when there's no connection
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isConnected = true;
  List<Function(bool)> _listeners = [];
  
  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(_updateConnectionStatus);
  }
  
  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Could not check connectivity status: $e');
      _isConnected = false;
    }
  }
  
  /// Update connection status and notify listeners
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      _notifyListeners(_isConnected);
    }
  }
  
  /// Check if device is currently connected to internet
  bool get isConnected => _isConnected;
  
  /// Check connectivity and return result
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }
  
  /// Add listener for connectivity changes
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }
  
  /// Remove listener
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }
  
  /// Notify all listeners
  void _notifyListeners(bool isConnected) {
    for (var listener in _listeners) {
      listener(isConnected);
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }
}
