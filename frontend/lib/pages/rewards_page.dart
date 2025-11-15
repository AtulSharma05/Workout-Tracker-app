import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_stats.dart';
import '../services/workout_service.dart';
import '../theme/app_theme.dart';

/// Rewards & Achievements Page
/// Three tabs: Achievements, Rewards, Points & Tokens
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutService = context.watch<WorkoutService>();
    
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text(
          'Rewards & Achievements',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(
              icon: Icon(Icons.emoji_events),
              text: 'Achievements',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Rewards',
            ),
            Tab(
              icon: Icon(Icons.monetization_on),
              text: 'Points & Tokens',
            ),
          ],
        ),
      ),
      body: FutureBuilder<WorkoutStats>(
        future: _getStats(workoutService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }
          
          final stats = snapshot.data;
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAchievementsTab(stats),
              _buildRewardsTab(stats),
              _buildPointsTab(stats),
            ],
          );
        },
      ),
    );
  }
  
  Future<WorkoutStats> _getStats(WorkoutService service) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    return service.getStats(startDate: startDate, endDate: endDate);
  }
  
  // ACHIEVEMENTS TAB
  Widget _buildAchievementsTab(WorkoutStats? stats) {
    final achievements = _getAllAchievements(stats?.overview);
    final unlocked = achievements.where((a) => a['unlocked'] == true).length;
    final total = achievements.length;
    final progress = total > 0 ? (unlocked / total) : 0.0;
    
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Progress Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                    const Text(
                      'Achievement Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBrown,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlocked / $total',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkBrown.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Achievement Cards
          ...achievements.map((achievement) {
            return _buildAchievementCard(
              emoji: achievement['emoji'],
              title: achievement['title'],
              description: achievement['description'],
              unlocked: achievement['unlocked'],
              current: achievement['current'],
              target: achievement['target'],
              points: achievement['points'],
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildAchievementCard({
    required String emoji,
    required String title,
    required String description,
    required bool unlocked,
    required int current,
    required int target,
    required int points,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unlocked 
            ? Border.all(color: AppTheme.primaryGreen, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: unlocked 
                ? AppTheme.primaryGreen.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: unlocked 
                  ? AppTheme.primaryGreen.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black.withOpacity(unlocked ? 1.0 : 0.3),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: unlocked 
                              ? AppTheme.darkBrown 
                              : AppTheme.darkBrown.withOpacity(0.5),
                        ),
                      ),
                    ),
                    if (unlocked)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkBrown.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$current / $target',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkBrown.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                unlocked ? AppTheme.primaryGreen : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$points',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // REWARDS TAB
  Widget _buildRewardsTab(WorkoutStats? stats) {
    final points = _calculateTotalPoints(stats?.overview);
    final tokens = _calculateTotalTokens(stats?.overview);
    final rewards = _getAllRewards();
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Points Balance
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.orange, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$points Points',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text(
                      'Earned from achievements',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Tokens Balance (Future Feature)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade200, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.toll, color: Colors.purple, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$tokens Tokens',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Text(
                      'Blockchain rewards (Coming Soon)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Rewards List
        ...rewards.map((reward) {
          final canUnlock = points >= reward['cost']; // Uses points, not tokens
          return _buildRewardCard(
            emoji: reward['emoji'],
            title: reward['title'],
            description: reward['description'],
            cost: reward['cost'],
            locked: reward['locked'],
            canUnlock: canUnlock,
          );
        }),
      ],
    );
  }
  
  Widget _buildRewardCard({
    required String emoji,
    required String title,
    required String description,
    required int cost,
    required bool locked,
    required bool canUnlock,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: locked 
                  ? Colors.grey.withOpacity(0.1)
                  : AppTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black.withOpacity(locked ? 0.3 : 1.0),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: locked 
                        ? AppTheme.darkBrown.withOpacity(0.5)
                        : AppTheme.darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkBrown.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$cost points',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: locked 
                  ? Colors.grey.withOpacity(0.2)
                  : AppTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              locked ? 'Locked' : 'Unlocked',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: locked ? Colors.grey : AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // POINTS & TOKENS TAB
  Widget _buildPointsTab(WorkoutStats? stats) {
    final points = _calculateTotalPoints(stats?.overview);
    final tokens = _calculateTotalTokens(stats?.overview);
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Points Balance
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 64),
              const SizedBox(height: 8),
              Text(
                '$points',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Points',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Earned from app achievements',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tokens Balance
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.toll, color: Colors.white, size: 64),
              const SizedBox(height: 8),
              Text(
                '$tokens',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Tokens',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Blockchain rewards from live challenges',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        const Text(
          'How to Earn Points',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildEarnPointItem(
          icon: Icons.fitness_center,
          title: 'Complete a workout',
          points: 10,
        ),
        _buildEarnPointItem(
          icon: Icons.star,
          title: 'First workout milestone',
          points: 20,
        ),
        _buildEarnPointItem(
          icon: Icons.local_fire_department,
          title: 'Maintain 3-day streak',
          points: 30,
        ),
        _buildEarnPointItem(
          icon: Icons.emoji_events,
          title: 'Unlock achievement',
          points: 15,
        ),
        _buildEarnPointItem(
          icon: Icons.calendar_today,
          title: '7-day streak bonus',
          points: 50,
        ),
        _buildEarnPointItem(
          icon: Icons.trending_up,
          title: 'Complete 10 workouts',
          points: 100,
        ),
        
        const SizedBox(height: 32),
        
        const Text(
          'How to Earn Tokens',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200, width: 2),
          ),
          child: Column(
            children: [
              const Icon(Icons.schedule, color: Colors.purple, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Compete in live challenges against other users to earn blockchain-based tokens. This feature will be available soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkBrown.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEarnPointItem({
    required IconData icon,
    required String title,
    required int points,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkBrown,
              ),
            ),
          ),
          Text(
            '$points points',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  List<Map<String, dynamic>> _getAllAchievements(StatsOverview? overview) {
    final workouts = overview?.totalWorkouts ?? 0;
    final streak = overview?.currentStreak ?? 0;
    final calories = overview?.totalCalories.toInt() ?? 0;
    
    return [
      {
        'emoji': '🏃',
        'title': 'First Steps',
        'description': 'Complete your first workout',
        'current': workouts >= 1 ? 1 : 0,
        'target': 1,
        'unlocked': workouts >= 1,
        'points': 20,
      },
      {
        'emoji': '🔥',
        'title': 'Consistency',
        'description': 'Maintain a 3-day workout streak',
        'current': streak >= 3 ? 3 : streak,
        'target': 3,
        'unlocked': streak >= 3,
        'points': 30,
      },
      {
        'emoji': '⚡',
        'title': 'Weekly Warrior',
        'description': 'Maintain a 7-day workout streak',
        'current': streak >= 7 ? 7 : streak,
        'target': 7,
        'unlocked': streak >= 7,
        'points': 50,
      },
      {
        'emoji': '💯',
        'title': 'Committed',
        'description': 'Complete 10 workouts',
        'current': workouts >= 10 ? 10 : workouts,
        'target': 10,
        'unlocked': workouts >= 10,
        'points': 100,
      },
      {
        'emoji': '🔥',
        'title': 'On Fire',
        'description': 'Burn 1000 total calories',
        'current': calories >= 1000 ? 1000 : calories,
        'target': 1000,
        'unlocked': calories >= 1000,
        'points': 75,
      },
      {
        'emoji': '🏆',
        'title': 'Champion',
        'description': 'Maintain a 30-day streak',
        'current': streak >= 30 ? 30 : streak,
        'target': 30,
        'unlocked': streak >= 30,
        'points': 200,
      },
      {
        'emoji': '💪',
        'title': 'Beast Mode',
        'description': 'Complete 50 workouts',
        'current': workouts >= 50 ? 50 : workouts,
        'target': 50,
        'unlocked': workouts >= 50,
        'points': 250,
      },
    ];
  }
  
  List<Map<String, dynamic>> _getAllRewards() {
    return [
      {
        'emoji': '🎨',
        'title': 'Custom Theme',
        'description': 'Unlock custom app themes',
        'cost': 50,
        'locked': true,
      },
      {
        'emoji': '📊',
        'title': 'Advanced Statistics',
        'description': 'Detailed workout analytics',
        'cost': 100,
        'locked': true,
      },
      {
        'emoji': '📋',
        'title': 'Workout Templates',
        'description': 'Pre-made workout plans',
        'cost': 150,
        'locked': true,
      },
      {
        'emoji': '🤖',
        'title': 'AI Coach',
        'description': 'Personal AI workout assistant',
        'cost': 300,
        'locked': true,
      },
      {
        'emoji': '👥',
        'title': 'Community Access',
        'description': 'Join workout challenges',
        'cost': 200,
        'locked': true,
      },
    ];
  }
  
  int _calculateTotalPoints(StatsOverview? overview) {
    if (overview == null) return 0;
    
    int points = 0;
    final workouts = overview.totalWorkouts;
    final streak = overview.currentStreak;
    final calories = overview.totalCalories.toInt();
    
    // Points per workout
    points += workouts * 10;
    
    // Milestone bonuses
    if (workouts >= 1) points += 20; // First workout
    if (workouts >= 10) points += 100; // 10 workouts
    if (workouts >= 50) points += 250; // 50 workouts
    
    // Streak bonuses
    if (streak >= 3) points += 30;
    if (streak >= 7) points += 50;
    if (streak >= 30) points += 200;
    
    // Calorie milestone
    if (calories >= 1000) points += 75;
    
    return points;
  }
  
  int _calculateTotalTokens(StatsOverview? overview) {
    // Tokens are blockchain-based rewards for live challenges (future feature)
    // Will be implemented when live challenge system is ready
    return 0;
  }
}
