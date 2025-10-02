class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> m) {
    return User(
      id: m['id'] is String ? int.parse(m['id']) : m['id'] as int,
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      role: m['role'] ?? '',
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }

  factory User.fromMap(Map<String, dynamic> m) {
    return User(
      id: m['id'] is String ? int.parse(m['id']) : m['id'] as int,
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      role: m['role'] ?? '',
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
