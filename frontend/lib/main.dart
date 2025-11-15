import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/connectivity_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/workout_service.dart';
import 'config/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final connectivityService = ConnectivityService();
    final apiService = ApiService(connectivityService);
    final authService = AuthService(apiService);
    final workoutService = WorkoutService(apiService);

    return MultiProvider(
      providers: [
        Provider<ConnectivityService>.value(value: connectivityService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<WorkoutService>.value(value: workoutService),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = true;
  String _connectionStatus = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
    
    // Listen to connectivity changes
    final connectivityService = context.read<ConnectivityService>();
    connectivityService.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged(bool isConnected) {
    setState(() {
      _isConnected = isConnected;
      _connectionStatus = isConnected 
          ? 'Connected to network' 
          : 'No internet connection';
    });
  }

  Future<void> _checkConnection() async {
    final connectivityService = context.read<ConnectivityService>();
    final isConnected = await connectivityService.checkConnectivity();
    
    setState(() {
      _isConnected = isConnected;
      _connectionStatus = isConnected 
          ? 'Connected to network' 
          : 'No internet connection';
    });
  }

  Future<void> _testBackendConnection() async {
    final apiService = context.read<ApiService>();
    
    setState(() {
      _connectionStatus = 'Testing backend connection...';
    });

    try {
      // Make a test request to the health endpoint
      final response = await apiService.get('/../../health');
      
      setState(() {
        _connectionStatus = 'Backend connected! ✅\n${response.data['message']}';
        _isConnected = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to backend!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Backend connection failed ❌\n$e';
        _isConnected = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend connection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          Icon(
            _isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Connection Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_connectionStatus),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API Configuration Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ApiConfig.baseUrl}'),
                    const SizedBox(height: 4),
                    const Text(
                      'This URL is automatically selected based on your device:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Android Emulator: ${ApiConfig.localhostUrl.replaceAll('localhost', '10.0.2.2')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '• iOS Simulator: ${ApiConfig.localhostUrl}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '• Physical Devices: ${ApiConfig.networkUrl}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Connection Button
            ElevatedButton.icon(
              onPressed: _testBackendConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Test Backend Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Important Notice
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Make sure the backend server is running\n'
                      '2. For physical devices, update your network IP in lib/config/api_config.dart\n'
                      '3. Ensure your device and computer are on the same WiFi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Next Steps
            const Text(
              'Next Steps:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Once backend connection is successful\n'
              '• Build authentication screens\n'
              '• Implement workout CRUD operations\n'
              '• Add offline caching with Hive',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    final connectivityService = context.read<ConnectivityService>();
    connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
