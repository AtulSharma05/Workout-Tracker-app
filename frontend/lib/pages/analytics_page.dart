import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_stats.dart';
import '../services/workout_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Analytics Page
/// Shows real workout statistics with charts
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = '30'; // days
  
  @override
  Widget build(BuildContext context) {
    final workoutService = context.watch<WorkoutService>();
    
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text(
          'Workout Analytics',
          style: TextStyle(color: AppTheme.darkBrown),
        ),
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.3),
        elevation: 0,
        actions: [
          // Period selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: AppTheme.darkBrown),
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90', child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<WorkoutStats>(
        future: _getStats(workoutService),
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
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }
          
          final stats = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period info
                  Text(
                    '${DateFormat('MMM d').format(stats.period.startDate)} - ${DateFormat('MMM d, y').format(stats.period.endDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Overview cards
                  _buildOverviewCards(stats.overview),
                  
                  const SizedBox(height: 28),
                  
                  // Weekly progress chart
                  if (stats.weeklyProgress.isNotEmpty) ...[
                    _buildSectionTitle('Weekly Progress'),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(stats.weeklyProgress),
                    const SizedBox(height: 28),
                  ],
                  
                  // Workouts by type
                  if (stats.workoutsByType.isNotEmpty) ...[
                    _buildSectionTitle('Workout Types'),
                    const SizedBox(height: 16),
                    _buildWorkoutTypesPie(stats.workoutsByType),
                    const SizedBox(height: 20),
                    _buildWorkoutTypesList(stats.workoutsByType),
                    const SizedBox(height: 28),
                  ],
                  
                  // Top exercises
                  if (stats.topExercises.isNotEmpty) ...[
                    _buildSectionTitle('Top Exercises'),
                    const SizedBox(height: 16),
                    _buildTopExercises(stats.topExercises),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<WorkoutStats> _getStats(WorkoutService service) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: int.parse(_selectedPeriod)));
    return service.getStats(startDate: startDate, endDate: endDate);
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkBrown,
      ),
    );
  }
  
  Widget _buildOverviewCards(StatsOverview overview) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.fitness_center,
                label: 'Total\nWorkouts',
                value: overview.totalWorkouts.toString(),
                color: AppTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '${overview.currentStreak} days',
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.timer,
                label: 'Total Time',
                value: '${overview.totalDuration.toInt()} min',
                color: AppTheme.primaryPink.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.whatshot,
                label: 'Calories',
                value: overview.totalCalories.toInt().toString(),
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildWeeklyChart(List<WeeklyProgress> weeklyData) {
    // Take last 8 weeks
    final data = weeklyData.length > 8 
        ? weeklyData.sublist(weeklyData.length - 8) 
        : weeklyData;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workouts per Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBrown,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data.map((e) => e.workoutCount).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[value.toInt()].label,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.workoutCount.toDouble(),
                        color: AppTheme.primaryGreen,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutTypesPie(List<WorkoutByType> types) {
    final colors = {
      'cardio': Colors.orange,
      'strength': AppTheme.primaryGreen,
      'flexibility': Colors.purple,
      'sports': Colors.blue,
      'other': Colors.grey,
    };
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: types.map((type) {
              final color = colors[type.type] ?? Colors.grey;
              return PieChartSectionData(
                color: color,
                value: type.count.toDouble(),
                title: '${type.count}',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWorkoutTypesList(List<WorkoutByType> types) {
    final colors = {
      'cardio': Colors.orange,
      'strength': AppTheme.primaryGreen,
      'flexibility': Colors.purple,
      'sports': Colors.blue,
      'other': Colors.grey,
    };
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: types.map((type) {
          final color = colors[type.type] ?? Colors.grey;
          return ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              type.type.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${type.totalDuration.toInt()} min • ${type.totalCalories.toInt()} cal',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '${type.count} workouts',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTopExercises(List<TopExercise> exercises) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: exercises.take(5).map((exercise) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
              child: Text(
                '${exercise.count}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBrown,
                ),
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Avg: ${exercise.avgDuration.toInt()} min • ${exercise.avgCalories.toInt()} cal',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.darkBrown.withOpacity(0.6), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.darkBrown.withOpacity(0.7),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
