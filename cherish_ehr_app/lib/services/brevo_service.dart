import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class BrevoService {
  static final BrevoService _instance = BrevoService._internal();
  late String _apiKey;
  final ConfigService _configService = ConfigService();

  factory BrevoService() {
    return _instance;
  }

  BrevoService._internal();

  Future<void> init() async {
    _apiKey = await _configService.getApiKey() ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Brevo API key not found');
    }
  }

  String get apiKey => _apiKey;
  final String baseUrl = 'https://api.brevo.com/v3';

  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
  }) async {
    final url = Uri.parse('$baseUrl/smtp/email');
    final response = await http.post(
      url,
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': {'name': 'Cherish Orthopaedic Centre', 'email': 'no-reply@cherishclinic.com'},
        'to': [
          {'email': toEmail}
        ],
        'subject': subject,
        'htmlContent': htmlContent,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> sendSms({
    required String toNumber,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/transactionalSMS/sms');
    final response = await http.post(
      url,
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': 'CherishClinic',
        'recipient': toNumber,
        'content': message,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> sendMarketingCampaign({
    required List<String> emails,
    required String subject,
    required String htmlContent,
    String? templateId,
  }) async {
    final url = Uri.parse('$baseUrl/emailCampaigns');
    final response = await http.post(
      url,
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': 'Marketing Campaign - ${DateTime.now().toIso8601String()}',
        'subject': subject,
        'sender': {'name': 'Cherish Orthopaedic Centre', 'email': 'no-reply@cherishclinic.com'},
        'recipients': {'listIds': emails},
        'htmlContent': htmlContent,
        if (templateId != null) 'templateId': templateId,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> sendBulkSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/transactionalSMS/bulk');
    final response = await http.post(
      url,
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': 'CherishClinic',
        'recipients': phoneNumbers,
        'content': message,
      }),
    );
    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>> getMarketingStats({
    required String campaignId,
  }) async {
    final url = Uri.parse('$baseUrl/emailCampaigns/$campaignId/statistics');
    final response = await http.get(
      url,
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get campaign statistics');
  }
}
