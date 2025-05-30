import 'package:flutter/foundation.dart';
import 'brevo_service.dart';

class MarketingService {
  static final MarketingService _instance = MarketingService._internal();
  factory MarketingService() => _instance;
  MarketingService._internal();

  final BrevoService _brevoService = BrevoService();

  Future<bool> sendEmailCampaign({
    required List<String> recipients,
    required String subject,
    required String content,
    String? templateId,
  }) async {
    try {
      return await _brevoService.sendMarketingCampaign(
        emails: recipients,
        subject: subject,
        htmlContent: content,
        templateId: templateId,
      );
    } catch (e) {
      debugPrint('Error sending email campaign: $e');
      return false;
    }
  }

  Future<bool> sendBulkSmsNotification({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    try {
      return await _brevoService.sendBulkSms(
        phoneNumbers: phoneNumbers,
        message: message,
      );
    } catch (e) {
      debugPrint('Error sending bulk SMS: $e');
      return false;
    }
  }

  Future<bool> sendHealthTipsNewsletter({
    required List<String> recipients,
    required String title,
    required String content,
  }) async {
    final subject = 'Health Tips from Cherish Orthopaedic Centre - $title';
    final htmlContent = '''
      <h1>$title</h1>
      <div>$content</div>
      <br>
      <p>Best regards,</p>
      <p>Cherish Orthopaedic Centre</p>
      <p><small>To unsubscribe from these newsletters, please click <a href="#">here</a>.</small></p>
    ''';

    return await sendEmailCampaign(
      recipients: recipients,
      subject: subject,
      content: htmlContent,
    );
  }

  Future<bool> sendSpecialOfferSms({
    required List<String> phoneNumbers,
    required String offerDetails,
  }) async {
    final message = '''
      Special Offer from Cherish Orthopaedic Centre!
      $offerDetails
      Book now: +254700000000
      Reply STOP to opt out.
    '''.trim();

    return await sendBulkSmsNotification(
      phoneNumbers: phoneNumbers,
      message: message,
    );
  }

  Future<bool> sendPromotionalEmail({
    required List<String> recipients,
    required String subject,
    required String content,
  }) async {
    final htmlContent = '''
      <div style="font-family: Arial, sans-serif;">
        <h1>$subject</h1>
        $content
        <br>
        <p>Visit us at Cherish Orthopaedic Centre</p>
        <p>For appointments, call: +254700000000</p>
        <p><small>To unsubscribe from promotional emails, click <a href="#">here</a>.</small></p>
      </div>
    ''';

    return await sendEmailCampaign(
      recipients: recipients,
      subject: "Cherish Orthopaedic Centre - $subject",
      content: htmlContent,
    );
  }

  Future<bool> sendPromotionalSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final formattedMessage = '''
      Cherish Orthopaedic Centre:
      $message
      Call +254700000000
      Reply STOP to opt out.
    '''.trim();

    return await sendBulkSmsNotification(
      phoneNumbers: phoneNumbers,
      message: formattedMessage,
    );
  }

  Future<bool> sendAppointmentReminders({
    required List<String> recipients,
    required String appointmentDate,
    required String doctorName,
  }) async {
    final subject = 'Appointment Reminder - Cherish Orthopaedic Centre';
    final content = '''
      <h1>Appointment Reminder</h1>
      <p>Dear Patient,</p>
      <p>This is a reminder for your upcoming appointment:</p>
      <ul>
        <li>Date: $appointmentDate</li>
        <li>Doctor: $doctorName</li>
      </ul>
      <p>Please arrive 15 minutes before your scheduled appointment time.</p>
      <p>If you need to reschedule, please contact us at least 24 hours in advance.</p>
      <br>
      <p>Best regards,</p>
      <p>Cherish Orthopaedic Centre</p>
    ''';

    return await sendEmailCampaign(
      recipients: recipients,
      subject: subject,
      content: content,
    );
  }

  Future<bool> sendFollowUpReminders({
    required List<String> phoneNumbers,
    required String appointmentDate,
  }) async {
    final message = '''
      Reminder: Your follow-up appointment at Cherish Orthopaedic Centre is scheduled for $appointmentDate. 
      Please confirm your attendance. If you need to reschedule, call us at +254700000000.
    ''';

    return await sendBulkSmsNotification(
      phoneNumbers: phoneNumbers,
      message: message,
    );
  }

  Future<Map<String, dynamic>> getCampaignStatistics(String campaignId) async {
    try {
      return await _brevoService.getMarketingStats(campaignId: campaignId);
    } catch (e) {
      debugPrint('Error getting campaign statistics: $e');
      return {
        'error': e.toString(),
        'status': 'failed',
      };
    }
  }
}
