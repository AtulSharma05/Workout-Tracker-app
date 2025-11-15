/// Workout Model
class Workout {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Workout({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      if (description != null) 'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

/// Exercise Model
class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double? weight;
  final String? notes;
  
  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.notes,
  });
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
    };
  }
}
