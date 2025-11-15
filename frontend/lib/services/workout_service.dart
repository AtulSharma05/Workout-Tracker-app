import '../config/api_config.dart';
import '../models/workout.dart';
import 'api_service.dart';

/// Workout Service
/// Handles all workout-related API calls
class WorkoutService {
  final ApiService _apiService;
  
  WorkoutService(this._apiService);
  
  /// Get all workouts for the current user
  Future<List<Workout>> getWorkouts() async {
    try {
      final response = await _apiService.get(ApiConfig.workoutEndpoint);
      
      final List<dynamic> workoutsJson = response.data['workouts'] ?? response.data;
      return workoutsJson.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }
  
  /// Get a specific workout by ID
  Future<Workout> getWorkout(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.workoutEndpoint}/$id');
      return Workout.fromJson(response.data['workout'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch workout: $e');
    }
  }
  
  /// Create a new workout
  Future<Workout> createWorkout(Workout workout) async {
    try {
      final response = await _apiService.post(
        ApiConfig.workoutEndpoint,
        data: workout.toJson(),
      );
      
      return Workout.fromJson(response.data['workout'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }
  
  /// Update an existing workout
  Future<Workout> updateWorkout(String id, Workout workout) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.workoutEndpoint}/$id',
        data: workout.toJson(),
      );
      
      return Workout.fromJson(response.data['workout'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }
  
  /// Delete a workout
  Future<void> deleteWorkout(String id) async {
    try {
      await _apiService.delete('${ApiConfig.workoutEndpoint}/$id');
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }
}
