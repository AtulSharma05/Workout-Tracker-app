import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'rewards_page.dart';
import 'home_page.dart';

/// Features Page
/// Grid of feature cards for main app functionality
class FeaturesPage extends StatelessWidget {
  final Function(int)? onSwitchTab;
  
  const FeaturesPage({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBrown),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text(
          'Features',
          style: TextStyle(
            color: AppTheme.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore all features to enhance your fitness journey',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkBrown.withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions Section
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Log Workout',
                    subtitle: 'Track exercise',
                    icon: Icons.add_circle,
                    color: AppTheme.primaryGreen,
                    onTap: () => Navigator.pushNamed(context, '/log-workout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: 'History',
                    subtitle: 'View workouts',
                    icon: Icons.history,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/workout-history'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // All Features Section
            const Text(
              'All Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _FeatureCard(
                  title: 'Analytics',
                  icon: Icons.bar_chart,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'Stats',
                  onTap: () {
                    // Navigate to analytics tab (index 0)
                    if (onSwitchTab != null) {
                      onSwitchTab!(0);
                    }
                  },
                ),
                _FeatureCard(
                  title: 'Streak',
                  icon: Icons.local_fire_department,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF9A56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'Rewards',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RewardsPage(),
                      ),
                    );
                  },
                ),
                _FeatureCard(
                  title: 'AI Chatbot',
                  icon: Icons.smart_toy,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'Coming Soon',
                  enabled: false,
                  onTap: () {
                    _showComingSoonDialog(context, 'AI Chatbot');
                  },
                ),
                _FeatureCard(
                  title: 'Pose Detection',
                  icon: Icons.videocam,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEE0979), Color(0xFFFF6A00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'Coming Soon',
                  enabled: false,
                  onTap: () {
                    _showComingSoonDialog(context, 'AI Pose Detection');
                  },
                ),
                _FeatureCard(
                  title: 'Workout Plans',
                  icon: Icons.auto_awesome,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF834D9B), Color(0xFFD04ED6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'AI',
                  onTap: () {
                    Navigator.pushNamed(context, '/create-workout-plan');
                  },
                ),
                _FeatureCard(
                  title: 'Community',
                  icon: Icons.groups,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  badge: 'Coming Soon',
                  enabled: false,
                  onTap: () {
                    _showComingSoonDialog(context, 'Community');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.rocket_launch, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Text(feature),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This feature is coming soon!',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBrown.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'re working hard to bring you $feature. Stay tuned for updates!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkBrown.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkBrown.withOpacity(0.6),
              ),
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
  final Gradient gradient;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.gradient,
    this.badge,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: enabled ? gradient : LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: enabled 
                  ? gradient.colors.first.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Badge
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: enabled ? gradient.colors.first : Colors.grey,
                    ),
                  ),
                ),
              ),
            
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: Colors.white.withOpacity(enabled ? 1.0 : 0.6),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(enabled ? 1.0 : 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
