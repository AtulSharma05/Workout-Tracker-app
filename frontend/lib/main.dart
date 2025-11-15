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
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
