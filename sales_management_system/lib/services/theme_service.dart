import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  SharedPreferences? _prefs;
  bool _isDarkMode = false;

  ThemeService() {
    _loadThemeMode();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
}
