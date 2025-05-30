import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'user_role.dart';

class User {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final UserRole role;
  final String? passwordHash;
  final String? resetToken;
  final DateTime? resetTokenExpiry;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  User({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    this.passwordHash,
    this.resetToken,
    this.resetTokenExpiry,
    DateTime? createdAt,
    this.lastLogin,
    this.isActive = true,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'passwordHash': passwordHash,
      'resetToken': resetToken,
      'resetTokenExpiry': resetTokenExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      role: UserRole.fromString(map['role']),
      passwordHash: map['passwordHash'],
      resetToken: map['resetToken'],
      resetTokenExpiry: map['resetTokenExpiry'] != null
          ? DateTime.parse(map['resetTokenExpiry'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
      isActive: map['isActive'] == 1,
    );
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  bool verifyPassword(String password) {
    final hashedInput = hashPassword(password);
    return hashedInput == passwordHash;
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    String? passwordHash,
    String? resetToken,
    DateTime? resetTokenExpiry,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      resetToken: resetToken ?? this.resetToken,
      resetTokenExpiry: resetTokenExpiry ?? this.resetTokenExpiry,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  String get fullName => '$firstName $lastName';

  bool get canResetPassword {
    if (resetToken == null || resetTokenExpiry == null) return false;
    return resetTokenExpiry!.isAfter(DateTime.now());
  }

  static String generateResetToken() {
    final random = List<int>.generate(32, (_) => DateTime.now().microsecond % 256);
    return base64Url.encode(random);
  }

  static DateTime generateResetTokenExpiry() {
    return DateTime.now().add(Duration(hours: 24));
  }
}
