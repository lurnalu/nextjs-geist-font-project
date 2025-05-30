import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService extends ChangeNotifier {
  static const String _userIdKey = 'userId';
  static const String _userRoleKey = 'userRole';
  
  final DatabaseHelper _db = DatabaseHelper();
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    
    if (userId != null) {
      try {
        final db = await _db.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        if (maps.isNotEmpty) {
          _currentUser = User.fromMap(maps.first);
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error initializing auth service: $e');
      }
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ? AND password = ? AND isActive = 1',
        whereArgs: [username, password], // In production, use hashed password
      );

      if (maps.isNotEmpty) {
        _currentUser = User.fromMap(maps.first);
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_userIdKey, _currentUser!.id!);
        await prefs.setString(_userRoleKey, _currentUser!.role.toString());
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey);
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null) return false;

      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ? AND password = ?',
        whereArgs: [_currentUser!.id, currentPassword],
      );

      if (maps.isNotEmpty) {
        await db.update(
          'users',
          {'password': newPassword},
          where: 'id = ?',
          whereArgs: [_currentUser!.id],
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }

  bool hasPermission(List<UserRole> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.role);
  }

  Future<bool> createUser({
    required String username,
    required String password,
    required UserRole role,
    String? fullName,
    String? email,
  }) async {
    try {
      if (_currentUser?.role != UserRole.admin) return false;

      final db = await _db.database;
      final id = await db.insert('users', {
        'username': username,
        'password': password, // In production, hash the password
        'role': role.toString().split('.').last,
        'fullName': fullName,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': 1,
      });

      return id > 0;
    } catch (e) {
      debugPrint('Create user error: $e');
      return false;
    }
  }
}
