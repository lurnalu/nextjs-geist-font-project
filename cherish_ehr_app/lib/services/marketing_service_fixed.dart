import 'brevo_service.dart';
import 'database_service.dart';

class MarketingService {
  final BrevoService _brevoService;
  final DatabaseService _databaseService;

  MarketingService()
      : _brevoService = BrevoService(),
        _databaseService = DatabaseService();

  Future<bool> sendHealthTipsNewsletter() async {
    try {
      final patients = await _databaseService.getPatients();
      final emails = patients
          .where((p) => p['email'] != null && p['email'].toString().isNotEmpty)
          .map((p) => p['email'].toString())
          .toList();

      if (emails.isEmpty) {
        throw Exception('No valid email addresses found');
      }

      return await _brevoService.sendMarketingCampaign(
        emails: emails,
        subject: 'Monthly Health Tips from Cherish Orthopaedic Centre',
        htmlContent: _getHealthTipsTemplate(),
        campaignName: 'Monthly Health Tips Newsletter',
      );
    } catch (e) {
      print('Error sending health tips newsletter: $e');
      return false;
    }
  }

  Future<bool> sendSpecialOfferSms() async {
    try {
      final patients = await _databaseService.getPatients();
      final phoneNumbers = patients
          .where((p) => p['phone'] != null && p['phone'].toString().isNotEmpty)
          .map((p) => p['phone'].toString())
          .toList();

      if (phoneNumbers.isEmpty) {
        throw Exception('No valid phone numbers found');
      }

      return await _brevoService.sendBulkSms(
        phoneNumbers: phoneNumbers,
        message: _getSpecialOfferMessage(),
        campaignName: 'Special Offer SMS Campaign',
      );
    } catch (e) {
      print('Error sending special offer SMS: $e');
      return false;
    }
  }

  Future<bool> sendPromotionalEmail({
    required String campaignName,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final patients = await _databaseService.getPatients();
      final emails = patients
          .where((p) => p['email'] != null && p['email'].toString().isNotEmpty)
          .map((p) => p['email'].toString())
          .toList();

      if (emails.isEmpty) {
        throw Exception('No valid email addresses found');
      }

      return await _brevoService.sendMarketingCampaign(
        emails: emails,
        subject: subject,
        htmlContent: htmlContent,
        campaignName: campaignName,
      );
    } catch (e) {
      print('Error sending promotional email: $e');
      return false;
    }
  }

  Future<bool> sendPromotionalSms({
    required String campaignName,
    required String message,
  }) async {
    try {
      final patients = await _databaseService.getPatients();
      final phoneNumbers = patients
          .where((p) => p['phone'] != null && p['phone'].toString().isNotEmpty)
          .map((p) => p['phone'].toString())
          .toList();

      if (phoneNumbers.isEmpty) {
        throw Exception('No valid phone numbers found');
      }

      return await _brevoService.sendBulkSms(
        phoneNumbers: phoneNumbers,
        message: message,
        campaignName: campaignName,
      );
    } catch (e) {
      print('Error sending promotional SMS: $e');
      return false;
    }
  }

  String _getHealthTipsTemplate() {
    return '''
      <html>
        <body>
          <h1>Monthly Health Tips from Cherish Orthopaedic Centre</h1>
          <p>Dear Patient,</p>
          <p>Here are some important health tips for this month:</p>
          <ul>
            <li>Maintain good posture while working</li>
            <li>Exercise regularly for bone health</li>
            <li>Stay hydrated throughout the day</li>
            <li>Get adequate calcium and vitamin D</li>
          </ul>
          <p>Best regards,<br>Cherish Orthopaedic Centre Team</p>
        </body>
      </html>
    ''';
  }

  String _getSpecialOfferMessage() {
    return '''
      Special offer from Cherish Orthopaedic Centre!
      Book your consultation this week and get 20% off on physiotherapy sessions.
      Call us at: [Your Clinic Number]
    ''';
  }
}
