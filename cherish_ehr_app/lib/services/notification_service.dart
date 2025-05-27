import 'brevo_service.dart';

class NotificationService {
  final BrevoService brevoService;

  NotificationService(this.brevoService);

  Future<bool> sendAppointmentReminder({
    required String email,
    required String phoneNumber,
    required String patientName,
    required String appointmentDate,
  }) async {
    final emailSubject = 'Appointment Reminder - Cherish Orthopaedic Centre';
    final emailContent = '''
      <p>Dear \$patientName,</p>
      <p>This is a reminder for your appointment scheduled on \$appointmentDate at Cherish Orthopaedic Centre.</p>
      <p>Please contact us if you need to reschedule.</p>
      <p>Thank you!</p>
    ''';

    final smsMessage = 'Reminder: Your appointment at Cherish Orthopaedic Centre is on \$appointmentDate.';

    final emailSent = await brevoService.sendEmail(
      toEmail: email,
      subject: emailSubject,
      htmlContent: emailContent,
    );

    final smsSent = await brevoService.sendSms(
      toNumber: phoneNumber,
      message: smsMessage,
    );

    return emailSent && smsSent;
  }

  // Additional notification methods can be added here
}
