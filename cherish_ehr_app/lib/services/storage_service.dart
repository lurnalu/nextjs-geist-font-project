import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<void> write(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> read(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> delete(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> deleteAll() async {
    await _prefs?.clear();
  }

  bool get isInitialized => _isInitialized;
}
