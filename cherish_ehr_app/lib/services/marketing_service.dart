import 'brevo_service.dart';
import 'database_service.dart';

class MarketingService {
  static final MarketingService _instance = MarketingService._internal();
  final BrevoService _brevoService = BrevoService();
  final DatabaseService _databaseService = DatabaseService();

  factory MarketingService() {
    return _instance;
  }

  MarketingService._internal();

  Future<void> init() async {
    await _brevoService.init();
    await _databaseService.init();
  }

  Future<bool> sendPromotionalEmail({
    required String campaignName,
    required String subject,
    required String htmlContent,
  }) async {
    // Get all patient emails from database
    final patients = await _databaseService.getPatients();
    final emails = patients.map((p) => p['email'] as String).toList();

    if (emails.isEmpty) {
      return false;
    }

    return await _brevoService.sendMarketingCampaign(
      emails: emails,
      subject: subject,
      htmlContent: htmlContent,
      campaignName: campaignName,
    );
  }

  Future<bool> sendPromotionalSms({
    required String campaignName,
    required String message,
  }) async {
    // Get all patient phone numbers from database
    final patients = await _databaseService.getPatients();
    final phoneNumbers = patients.map((p) => p['phone'] as String).toList();

    if (phoneNumbers.isEmpty) {
      return false;
    }

    return await _brevoService.sendBulkSms(
      phoneNumbers: phoneNumbers,
      message: message,
      campaignName: campaignName,
    );
  }

  // Example promotional campaign templates
  Future<bool> sendHealthTipsNewsletter() async {
    const subject = 'Monthly Health Tips from Cherish Orthopaedic Centre';
    const htmlContent = '''
      <h1>Your Monthly Health Tips</h1>
      <p>Dear valued patient,</p>
      <p>Here are some tips for maintaining good orthopaedic health:</p>
      <ul>
        <li>Maintain good posture</li>
        <li>Exercise regularly</li>
        <li>Stay hydrated</li>
        <li>Get adequate rest</li>
      </ul>
      <p>Best regards,<br>Cherish Orthopaedic Centre</p>
    ''';

    return await sendPromotionalEmail(
      campaignName: 'Monthly Health Tips',
      subject: subject,
      htmlContent: htmlContent,
    );
  }

  Future<bool> sendSpecialOfferSms() async {
    const message = '''
      Cherish Orthopaedic Centre Special Offer!
      20% off on physiotherapy sessions this month.
      Book your appointment now.
      Terms and conditions apply.
    ''';

    return await sendPromotionalSms(
      campaignName: 'Monthly Special Offer',
      message: message,
    );
  }
}
