enum UserRole { admin, cashier, manager }

class User {
  final int? id;
  final String username;
  final String password;
  final UserRole role;
  final String? fullName;
  final String? email;
  final DateTime createdAt;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.fullName,
    this.email,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.toString().split('.').last,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
      ),
      fullName: map['fullName'],
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] == 1,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    UserRole? role,
    String? fullName,
    String? email,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
