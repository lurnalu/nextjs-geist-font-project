import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Future<void> init() async {
    await dotenv.load(fileName: '.env');
    
    // Store sensitive data in secure storage
    await _secureStorage.write(
      key: 'BREVO_API_KEY',
      value: dotenv.env['BREVO_API_KEY'],
    );
    await _secureStorage.write(
      key: 'SMTP_USERNAME',
      value: dotenv.env['SMTP_USERNAME'],
    );
    await _secureStorage.write(
      key: 'SMTP_PASSWORD',
      value: dotenv.env['SMTP_PASSWORD'],
    );
  }

  Future<String?> getBrevoApiKey() async {
    return await _secureStorage.read(key: 'BREVO_API_KEY');
  }

  Future<Map<String, String?>> getSmtpConfig() async {
    return {
      'host': dotenv.env['SMTP_HOST'],
      'port': dotenv.env['SMTP_PORT'],
      'username': await _secureStorage.read(key: 'SMTP_USERNAME'),
      'password': await _secureStorage.read(key: 'SMTP_PASSWORD'),
    };
  }

  // Add other configuration getters as needed
}
