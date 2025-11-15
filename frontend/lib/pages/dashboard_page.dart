import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_service.dart';
import '../theme/app_theme.dart';
import '../models/workout.dart';

/// Dashboard/Home Screen
/// Main landing page with workout stats and quick actions
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Workout> _recentWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentWorkouts();
  }

  Future<void> _loadRecentWorkouts() async {
    setState(() => _isLoading = true);
    
    try {
      final workoutService = context.read<WorkoutService>();
      final workouts = await workoutService.getWorkouts();
      
      setState(() {
        _recentWorkouts = workouts.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Silently fail - user might not have any workouts yet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecentWorkouts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickActionCard(
                      icon: Icons.fitness_center,
                      label: 'Start Workout',
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      onTap: () {
                        Navigator.pushNamed(context, '/log-workout');
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.emoji_events,
                      label: 'Rewards',
                      color: Colors.orange.withOpacity(0.2),
                      onTap: () {
                        // TODO: Navigate to rewards
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.bar_chart,
                      label: 'Progress',
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      onTap: () {
                        // Switch to analytics tab
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Workout Types Section
                Text(
                  'Workout Types',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.darkBrown,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _WorkoutTypeCard(
                        title: 'Strength Training',
                        subtitle: 'Build muscle and strength',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA8C5A5), Color(0xFFE5C7C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/log-workout');
                        },
                      ),
                      const SizedBox(width: 16),
                      _WorkoutTypeCard(
                        title: 'Cardio Workout',
                        subtitle: 'Improve cardiovascular health',
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/log-workout');
                        },
                      ),
                      const SizedBox(width: 16),
                      _WorkoutTypeCard(
                        title: 'Flexibility',
                        subtitle: 'Enhance mobility and balance',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB8A5C5), Color(0xFFE5C7C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/log-workout');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Recent Workouts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Workouts',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.darkBrown,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/workout-history');
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Recent Workouts List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_recentWorkouts.isEmpty)
                  _EmptyWorkoutsCard(
                    onAddWorkout: () {
                      Navigator.pushNamed(context, '/log-workout');
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryPink.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: _recentWorkouts.map((workout) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _WorkoutListItem(workout: workout),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/log-workout');
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(
          Icons.add,
          color: AppTheme.darkBrown,
          size: 32,
        ),
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.darkBrown,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workout Type Card Widget
class _WorkoutTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _WorkoutTypeCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workout List Item Widget
class _WorkoutListItem extends StatelessWidget {
  final Workout workout;

  const _WorkoutListItem({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getWorkoutColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getWorkoutIcon(),
            color: _getWorkoutColor(),
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Workout details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.exerciseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBrown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(workout.date)} • ${workout.duration} min',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkBrown.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        // Calories
        Text(
          '${workout.caloriesBurned.toInt()} cal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  IconData _getWorkoutIcon() {
    switch (workout.workoutType.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      case 'flexibility':
        return Icons.self_improvement;
      case 'sports':
        return Icons.sports_tennis;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getWorkoutColor() {
    switch (workout.workoutType.toLowerCase()) {
      case 'cardio':
        return Colors.orange;
      case 'strength':
        return AppTheme.primaryGreen;
      case 'flexibility':
        return Colors.purple;
      case 'sports':
        return Colors.blue;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

/// Empty Workouts Card
class _EmptyWorkoutsCard extends StatelessWidget {
  final VoidCallback onAddWorkout;

  const _EmptyWorkoutsCard({
    required this.onAddWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPink.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: AppTheme.darkBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your fitness journey today!',
            style: TextStyle(
              color: AppTheme.darkBrown.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddWorkout,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Workout'),
          ),
        ],
      ),
    );
  }
}
