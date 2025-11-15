import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/connectivity_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/workout_service.dart';
import 'theme/app_theme.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/log_workout_page.dart';
import 'pages/workout_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Set auth token before navigating to protected routes
          if (settings.name == '/home' || 
              settings.name == '/log-workout' || 
              settings.name == '/workout-history') {
            return MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: _setAuthToken(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    switch (settings.name) {
                      case '/home':
                        return const HomePage();
                      case '/log-workout':
                        return const LogWorkoutPage();
                      case '/workout-history':
                        return const WorkoutHistoryPage();
                      default:
                        return const WelcomePage();
                    }
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          }
          
          // Public routes
          return MaterialPageRoute(
            builder: (context) {
              switch (settings.name) {
                case '/login':
                  return const LoginPage();
                case '/register':
                  return const RegisterPage();
                default:
                  return const WelcomePage();
              }
            },
          );
        },
      ),
    );
  }
  
  Future<void> _setAuthToken(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final token = await authService.getToken();
    if (token != null) {
      apiService.setAuthToken(token);
    }
  }
}
