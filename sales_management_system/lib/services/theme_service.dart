import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  final SharedPreferences? _prefs;
  bool _isDarkMode = false;

  ThemeService() : _prefs = null {
    _loadThemeMode();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
}
