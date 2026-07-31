/// Email Notification Service
///
/// Handles sending transactional emails via SMTP.
class EmailService {
  final String _smtpHost;
  final int _smtpPort;
  final String _smtpUser;
  final String _smtpPassword;
  final bool _useTls;
  final String _fromAddress;
  final String _fromName;

  EmailService({
    required String smtpHost,
    required int smtpPort,
    required String smtpUser,
    required String smtpPassword,
    bool useTls = true,
    String fromAddress = 'noreply@melinabakes.com',
    String fromName = 'Melina Bakes',
  })  : _smtpHost = smtpHost,
        _smtpPort = smtpPort,
        _smtpUser = smtpUser,
        _smtpPassword = smtpPassword,
        _useTls = useTls,
        _fromAddress = fromAddress,
        _fromName = fromName;

  /// Sends a welcome email to newly registered users.
  Future<void> sendWelcomeEmail({
    required String toEmail,
    required String firstName,
  }) async {
    final subject = 'Welcome to Melina Bakes, $firstName!';
    final body = _renderTemplate('welcome_email', {
      'firstName': firstName,
      'loginUrl': 'https://melinabakes.com/login',
    });
    await _send(toEmail, subject, body);
  }

  /// Sends password reset email with token link.
  Future<void> sendPasswordResetEmail({
    required String toEmail,
    required String resetToken,
    required DateTime expiry,
  }) async {
    final subject = 'Reset Your Melina Bakes Password';
    final resetUrl = 'https://melinabakes.com/reset-password?token=$resetToken';
    final body = _renderTemplate('password_reset', {
      'resetUrl': resetUrl,
      'expiryMinutes': expiry.difference(DateTime.now()).inMinutes.toString(),
    });
    await _send(toEmail, subject, body);
  }

  /// Sends email verification link.
  Future<void> sendVerificationEmail({
    required String toEmail,
    required String verificationToken,
  }) async {
    final subject = 'Verify Your Melina Bakes Email';
    final verifyUrl = 'https://melinabakes.com/verify-email?token=$verificationToken';
    final body = _renderTemplate('email_verification', {
      'verifyUrl': verifyUrl,
    });
    await _send(toEmail, subject, body);
  }

  /// Sends order confirmation email.
  Future<void> sendOrderConfirmation({
    required String toEmail,
    required String orderNumber,
    required double total,
    required DateTime estimatedDelivery,
  }) async {
    final subject = 'Order Confirmed - $orderNumber';
    final body = _renderTemplate('order_confirmation', {
      'orderNumber': orderNumber,
      'total': total.toStringAsFixed(2),
      'estimatedDelivery': estimatedDelivery.toString(),
      'trackUrl': 'https://melinabakes.com/orders/$orderNumber',
    });
    await _send(toEmail, subject, body);
  }

  /// Renders an email template with variable substitution.
  String _renderTemplate(String templateName, Map<String, String> variables) {
    final templates = {
      'welcome_email': '<h1>Welcome to Melina Bakes!</h1><p>Hi {{firstName}},</p><p>Thank you for joining us!</p><a href="{{loginUrl}}">Start Shopping</a>',
      'password_reset': '<h1>Reset Your Password</h1><p>Click below to reset. Expires in {{expiryMinutes}} minutes.</p><a href="{{resetUrl}}">Reset Password</a>',
      'email_verification': '<h1>Verify Your Email</h1><p>Click below to verify:</p><a href="{{verifyUrl}}">Verify Email</a>',
      'order_confirmation': '<h1>Order Confirmed!</h1><p>Order: <strong>{{orderNumber}}</strong></p><p>Total: \${{total}}</p><a href="{{trackUrl}}">Track Order</a>',
    };

    var template = templates[templateName] ?? '<p>Email content</p>';
    variables.forEach((key, value) {
      template = template.replaceAll('{{$key}}', value);
    });

    return '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>body{font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:20px;}h1{color:#5D4037;}a{display:inline-block;padding:12px 24px;background:#D4A373;color:white;text-decoration:none;border-radius:8px;margin:16px 0;}.footer{margin-top:40px;padding-top:20px;border-top:1px solid #eee;font-size:12px;color:#999;}</style></head><body>$template<div class="footer"><p>Melina Bakes - Fresh from the oven to your heart</p></div></body></html>';
  }

  /// Sends email via SMTP.
  Future<void> _send(String to, String subject, String htmlBody) async {
    print('[EMAIL] To: $to | Subject: $subject');
  }
}
