import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/organic_background.dart';

/// Welcome Page
/// First screen users see with Sign in and Create account options
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrganicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                
                // Hello! text
                Text(
                  'Hello!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                      ),
                  textAlign: TextAlign.left,
                ),
                
                const SizedBox(height: 8),
                
                // Let's get started text
                Text(
                  "Let's get started",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                  textAlign: TextAlign.left,
                ),
                
                const Spacer(flex: 3),
                
                // Sign in button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Sign in'),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Create an account button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: AppTheme.darkBrown,
                    ),
                    child: const Text('Create an account'),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Terms & Conditions
                TextButton(
                  onPressed: () {
                    // TODO: Show terms and conditions
                  },
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: AppTheme.darkBrown,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
