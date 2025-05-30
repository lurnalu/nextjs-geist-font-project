import 'dart:async';
import '../models/user.dart';
import '../models/user_role.dart';
import 'database_service.dart';
import 'brevo_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final BrevoService _brevoService = BrevoService();
  final StorageService _storage = StorageService();
  
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  Stream<User?> get authStateChanges => _authStateController.stream;
  User? get currentUser => _currentUser;

  Future<void> init() async {
    // Initialize storage service
    await _storage.init();

    // Create users table if it doesn't exist
    final db = await _db.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        role TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        resetToken TEXT,
        resetTokenExpiry TEXT,
        createdAt TEXT NOT NULL,
        lastLogin TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Check if admin exists, if not create default admin
    final adminExists = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['admin'],
      limit: 1,
    );

    if (adminExists.isEmpty) {
      final adminUser = User(
        email: 'admin@cherishclinic.com',
        firstName: 'Admin',
        lastName: 'User',
        phoneNumber: '+254700000000',
        role: UserRole.admin,
        passwordHash: User.hashPassword('admin123'),
      );
      await db.insert('users', adminUser.toMap());
    }

    // Try to restore session
    await _restoreSession();
  }

  Future<void> _restoreSession() async {
    final userId = await _storage.read('userId');
    if (userId != null) {
      try {
        final user = await getUserById(int.parse(userId));
        if (user != null && user.isActive) {
          _currentUser = user;
          _authStateController.add(user);
        }
      } catch (e) {
        print('Error restoring session: $e');
        await _storage.delete('userId');
      }
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    final user = await getUserByEmail(email.toLowerCase());
    if (user == null) {
      throw Exception('User not found');
    }
    if (!user.isActive) {
      throw Exception('Account is disabled');
    }
    if (!user.verifyPassword(password)) {
      throw Exception('Invalid password');
    }

    final db = await _db.database;
    await db.update(
      'users',
      {'lastLogin': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    await _storage.write('userId', user.id.toString());
    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.delete('userId');
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    // Check if user exists
    final existingUser = await getUserByEmail(email.toLowerCase());
    if (existingUser != null) {
      throw Exception('Email already registered');
    }

    final user = User(
      email: email.toLowerCase(),
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
      passwordHash: User.hashPassword(password),
    );

    final db = await _db.database;
    final id = await db.insert('users', user.toMap());
    
    return user.copyWith(id: id);
  }

  Future<void> initiatePasswordReset(String email) async {
    final user = await getUserByEmail(email.toLowerCase());
    if (user == null) {
      throw Exception('User not found');
    }

    final resetToken = User.generateResetToken();
    final resetTokenExpiry = User.generateResetTokenExpiry();

    final db = await _db.database;
    await db.update(
      'users',
      {
        'resetToken': resetToken,
        'resetTokenExpiry': resetTokenExpiry.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );

    // Send reset email
    await _brevoService.sendEmail(
      toEmail: user.email,
      subject: 'Password Reset Request',
      htmlContent: '''
        <h1>Password Reset Request</h1>
        <p>Dear ${user.fullName},</p>
        <p>A password reset has been requested for your account. Click the link below to reset your password:</p>
        <p><a href="https://cherishclinic.com/reset-password?token=$resetToken">Reset Password</a></p>
        <p>This link will expire in 24 hours.</p>
        <p>If you did not request this reset, please ignore this email.</p>
      ''',
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: 'resetToken = ?',
      whereArgs: [token],
    );

    if (results.isEmpty) {
      throw Exception('Invalid reset token');
    }

    final user = User.fromMap(results.first);
    if (!user.canResetPassword) {
      throw Exception('Reset token has expired');
    }

    await db.update(
      'users',
      {
        'passwordHash': User.hashPassword(newPassword),
        'resetToken': null,
        'resetTokenExpiry': null,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> updatePassword(int userId, String currentPassword, String newPassword) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    if (!user.verifyPassword(currentPassword)) {
      throw Exception('Current password is incorrect');
    }

    final db = await _db.database;
    await db.update(
      'users',
      {'passwordHash': User.hashPassword(newPassword)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<User>> getUsers({UserRole? role}) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: role != null ? 'role = ?' : null,
      whereArgs: role != null ? [role.toString().split('.').last] : null,
    );
    return results.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUserStatus(int userId, bool isActive) async {
    if (_currentUser?.id == userId) {
      throw Exception('Cannot modify own account status');
    }

    final db = await _db.database;
    await db.update(
      'users',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  void dispose() {
    _authStateController.close();
  }
}
