import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Features Page
/// Grid of feature cards for main app functionality
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(
          'Features',
          style: TextStyle(color: AppTheme.lightGreen),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Open drawer
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _FeatureCard(
              title: 'Workout Blogs',
              icon: Icons.article,
              color: Colors.blue,
              onTap: () {
                // TODO: Navigate to blogs
              },
            ),
            _FeatureCard(
              title: 'Log Workout',
              icon: Icons.fitness_center,
              color: AppTheme.primaryGreen,
              onTap: () {
                Navigator.pushNamed(context, '/log-workout');
              },
            ),
            _FeatureCard(
              title: 'Workout History',
              icon: Icons.history,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/workout-history');
              },
            ),
            _FeatureCard(
              title: 'Streak & Rewards',
              icon: Icons.emoji_events,
              color: Colors.purple,
              onTap: () {
                // TODO: Navigate to rewards
              },
            ),
            _FeatureCard(
              title: 'Talk to AI/\nChatbot',
              icon: Icons.chat,
              color: Colors.teal,
              onTap: () {
                // TODO: Navigate to chatbot
              },
            ),
            _FeatureCard(
              title: 'AI Pose\nDetection',
              icon: Icons.camera_alt,
              color: Colors.red,
              onTap: () {
                // TODO: Navigate to pose detection
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
