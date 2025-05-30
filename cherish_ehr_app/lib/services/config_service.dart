import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<bool> isInitialized() async {
    return _isInitialized;
  }
  
  Future<void> init() async {
    if (_isInitialized) return;

    // Load .env file
    await dotenv.load();
    
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    
    // Set default values from .env if not already set
    if (!_prefs!.containsKey('api_key')) {
      await setApiKey(dotenv.env['BREVO_API_KEY'] ?? '');
    }
    
    if (!_prefs!.containsKey('api_url')) {
      await setApiUrl(dotenv.env['API_URL'] ?? 'https://api.brevo.com/v3');
    }
    
    if (!_prefs!.containsKey('email_sender')) {
      await setEmailSender(dotenv.env['EMAIL_SENDER'] ?? 'no-reply@cherishclinic.com');
    }
    
    if (!_prefs!.containsKey('sender_name')) {
      await setSenderName(dotenv.env['SENDER_NAME'] ?? 'Cherish Orthopaedic Centre');
    }

    _isInitialized = true;
  }

  Future<void> setApiKey(String key) async {
    await _prefs?.setString('api_key', key);
  }

  Future<String?> getApiKey() async {
    return _prefs?.getString('api_key');
  }

  Future<void> setApiUrl(String url) async {
    await _prefs?.setString('api_url', url);
  }

  Future<String?> getApiUrl() async {
    return _prefs?.getString('api_url');
  }

  Future<void> setEmailSender(String email) async {
    await _prefs?.setString('email_sender', email);
  }

  Future<String?> getEmailSender() async {
    return _prefs?.getString('email_sender');
  }

  Future<void> setSenderName(String name) async {
    await _prefs?.setString('sender_name', name);
  }

  Future<String?> getSenderName() async {
    return _prefs?.getString('sender_name');
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  // Helper method to check if all required configurations are set
  Future<bool> isConfigured() async {
    final apiKey = await getApiKey();
    final apiUrl = await getApiUrl();
    final emailSender = await getEmailSender();
    final senderName = await getSenderName();

    return apiKey != null && 
           apiKey.isNotEmpty && 
           apiUrl != null && 
           apiUrl.isNotEmpty &&
           emailSender != null && 
           emailSender.isNotEmpty &&
           senderName != null && 
           senderName.isNotEmpty;
  }
}
