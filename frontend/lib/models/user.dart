/// User Model for authentication and profile data
class User {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? name;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.name,
    required this.createdAt,
  });
  
  String get displayName => fullName ?? username ?? name ?? email.split('@').first;
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (username != null) 'username': username,
      if (fullName != null) 'fullName': fullName,
      if (name != null) 'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
