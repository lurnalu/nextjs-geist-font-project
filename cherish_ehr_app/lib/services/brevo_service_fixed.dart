import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class BrevoService {
  static final BrevoService _instance = BrevoService._internal();
  late String _apiKey;
  final String baseUrl = 'https://api.brevo.com/v3';

  factory BrevoService() {
    return _instance;
  }

  BrevoService._internal();

  Future<void> init() async {
    _apiKey = await ConfigService().getBrevoApiKey() ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Brevo API key not found');
    }
  }

  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
  }) async {
    final url = Uri.parse('$baseUrl/smtp/email');
    final response = await http.post(
      url,
      headers: {
        'api-key': _apiKey,
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
        'api-key': _apiKey,
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
    String campaignName = 'Default Campaign',
  }) async {
    final url = Uri.parse('$baseUrl/emailCampaigns');
    final response = await http.post(
      url,
      headers: {
        'api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': campaignName,
        'subject': subject,
        'sender': {'name': 'Cherish Orthopaedic Centre', 'email': 'no-reply@cherishclinic.com'},
        'recipients': {'listIds': emails},
        'htmlContent': htmlContent,
        'scheduledAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> sendBulkSms({
    required List<String> phoneNumbers,
    required String message,
    String campaignName = 'Default SMS Campaign',
  }) async {
    final url = Uri.parse('$baseUrl/smsCampaigns');
    final response = await http.post(
      url,
      headers: {
        'api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': campaignName,
        'sender': 'CherishClinic',
        'content': message,
        'recipients': phoneNumbers,
        'scheduledAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    return response.statusCode == 201;
  }
}
