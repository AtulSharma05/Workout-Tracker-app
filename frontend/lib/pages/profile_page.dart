import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/workout_stats.dart';
import '../services/auth_service.dart';
import '../services/workout_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

/// Profile Page
/// User profile with real workout stats and streak
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final workoutService = context.watch<WorkoutService>();
    
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
          'Profile',
          style: TextStyle(color: AppTheme.darkBrown),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.darkBrown),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadProfileData(authService, workoutService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final data = snapshot.data!;
          final user = data['user'] as User?;
          final stats = data['stats'] as WorkoutStats?;
          
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryPink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(user),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBrown,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // User Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkBrown.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Member since
                  if (user != null)
                    Text(
                      'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkBrown.withOpacity(0.5),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Workout Streak Card
                  _buildStreakCard(stats?.overview),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  if (stats?.overview != null) ...[
                    _buildStatsGrid(stats!.overview),
                    const SizedBox(height: 24),
                  ],
                  
                  // Workout Types Summary
                  if (stats?.workoutsByType != null && stats!.workoutsByType.isNotEmpty) ...[
                    _buildWorkoutTypesSummary(stats.workoutsByType),
                    const SizedBox(height: 24),
                  ],
                  
                  // Achievements/Badges Placeholder
                  _buildAchievementsSection(stats?.overview),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context, authService),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<Map<String, dynamic>> _loadProfileData(
    AuthService authService,
    WorkoutService workoutService,
  ) async {
    final user = await authService.getCurrentUser();
    
    WorkoutStats? stats;
    try {
      // Get stats for last 90 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 90));
      stats = await workoutService.getStats(startDate: startDate, endDate: endDate);
    } catch (e) {
      // Stats optional, don't fail if unavailable
      stats = null;
    }
    
    return {
      'user': user,
      'stats': stats,
    };
  }
  
  String _getInitials(User? user) {
    if (user == null) return '?';
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      final parts = user.fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return user.fullName![0].toUpperCase();
    }
    if (user.username != null && user.username!.isNotEmpty) {
      return user.username![0].toUpperCase();
    }
    return user.email[0].toUpperCase();
  }
  
  Widget _buildStreakCard(StatsOverview? overview) {
    final streak = overview?.currentStreak ?? 0;
    final nextMilestone = _getNextMilestone(streak);
    final progress = streak / nextMilestone;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Workout Streak',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    streak == 1 ? 'Day' : 'Days',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '💪 Keep going!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Next milestone: $nextMilestone days',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${(nextMilestone - streak).clamp(0, nextMilestone)} days to go',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  int _getNextMilestone(int streak) {
    const milestones = [7, 14, 30, 60, 100, 365];
    for (final milestone in milestones) {
      if (streak < milestone) return milestone;
    }
    return ((streak ~/ 100) + 1) * 100;
  }
  
  Widget _buildStatsGrid(StatsOverview overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center,
                label: 'Workouts',
                value: overview.totalWorkouts.toString(),
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                label: 'Minutes',
                value: overview.totalDuration.toInt().toString(),
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.whatshot,
                label: 'Calories',
                value: overview.totalCalories.toInt().toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.show_chart,
                label: 'Avg/Workout',
                value: '${overview.avgDuration.toInt()} min',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkBrown.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutTypesSummary(List<WorkoutByType> types) {
    final colors = {
      'cardio': Colors.orange,
      'strength': AppTheme.primaryGreen,
      'flexibility': Colors.purple,
      'sports': Colors.blue,
      'other': Colors.grey,
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: types.map((type) {
              final color = colors[type.type] ?? Colors.grey;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fitness_center, size: 24, color: color),
                ),
                title: Text(
                  type.type.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${type.totalDuration.toInt()} min',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${type.count}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementsSection(StatsOverview? overview) {
    final achievements = _getAchievements(overview);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievements.map((achievement) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: achievement['unlocked'] 
                    ? AppTheme.primaryGreen.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: achievement['unlocked']
                      ? AppTheme.primaryGreen
                      : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    achievement['icon'],
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black.withOpacity(achievement['unlocked'] ? 1.0 : 0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    achievement['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: achievement['unlocked']
                          ? AppTheme.darkBrown
                          : AppTheme.darkBrown.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  List<Map<String, dynamic>> _getAchievements(StatsOverview? overview) {
    final workouts = overview?.totalWorkouts ?? 0;
    final streak = overview?.currentStreak ?? 0;
    final calories = overview?.totalCalories ?? 0;
    
    return [
      {'icon': '🏁', 'name': 'First Workout', 'unlocked': workouts >= 1},
      {'icon': '🔥', 'name': '7 Day Streak', 'unlocked': streak >= 7},
      {'icon': '💯', 'name': '10 Workouts', 'unlocked': workouts >= 10},
      {'icon': '⚡', 'name': '1000 Calories', 'unlocked': calories >= 1000},
      {'icon': '🏆', 'name': '30 Day Streak', 'unlocked': streak >= 30},
      {'icon': '💪', 'name': '50 Workouts', 'unlocked': workouts >= 50},
    ];
  }
  
  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      await authService.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}
