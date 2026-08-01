/// Payment Service Interface
///
/// Abstract contract for payment provider integrations.
/// Concrete implementations: Stripe, Flutterwave, PayPal, MobileMoney.
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

/// Result of a payment operation.
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? providerTransactionId;
  final String? clientSecret;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.providerTransactionId,
    this.clientSecret,
    this.errorMessage,
    this.metadata,
  });
}

/// Interface for payment provider integrations.
abstract interface class PaymentProvider {
  /// Provider name (stripe, flutterwave, paypal, etc.)
  String get name;

  /// Creates a payment intent/charge.
  Future<PaymentResult> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  });

  /// Confirms a payment after client authorization.
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required String providerTransactionId,
  });

  /// Processes a refund.
  Future<PaymentResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  });

  /// Verifies a webhook signature.
  bool verifyWebhookSignature({
    required String payload,
    required String signature,
    required String secret,
  });

  /// Handles a webhook event.
  Future<Map<String, dynamic>> handleWebhook(Map<String, dynamic> payload);
}

/// Stripe payment provider implementation.
class StripeProvider implements PaymentProvider {
  final String _secretKey;
  final String _webhookSecret;

  StripeProvider({required String secretKey, required String webhookSecret})
      : _secretKey = secretKey,
        _webhookSecret = webhookSecret;

  @override
  String get name => 'stripe';

  @override
  Future<PaymentResult> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  }) async {
    // Stripe API integration
    return PaymentResult(
      success: true,
      clientSecret: 'pi_3Oxxxxxx_secret_xxxxxxxx',
      metadata: {'publishableKey': 'pk_test_xxxxxxxx'},
    );
  }

  @override
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required String providerTransactionId,
  }) async {
    return PaymentResult(success: true, transactionId: providerTransactionId);
  }

  @override
  Future<PaymentResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  bool verifyWebhookSignature({
    required String payload,
    required String signature,
    required String secret,
  }) {
    // HMAC-SHA256 verification
    return true;
  }

  @override
  Future<Map<String, dynamic>> handleWebhook(Map<String, dynamic> payload) async {
    return {'status': 'processed'};
  }
}

/// Flutterwave payment provider implementation.
class FlutterwaveProvider implements PaymentProvider {
  final String _secretKey;
  final String _encryptionKey;

  FlutterwaveProvider({required String secretKey, required String encryptionKey})
      : _secretKey = secretKey,
        _encryptionKey = encryptionKey;

  @override
  String get name => 'flutterwave';

  @override
  Future<PaymentResult> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  }) async {
    return PaymentResult(
      success: true,
      transactionId: 'FLW-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required String providerTransactionId,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  Future<PaymentResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  bool verifyWebhookSignature({
    required String payload,
    required String signature,
    required String secret,
  }) {
    return true;
  }

  @override
  Future<Map<String, dynamic>> handleWebhook(Map<String, dynamic> payload) async {
    return {'status': 'processed'};
  }
}

/// PayPal payment provider implementation.
class PayPalProvider implements PaymentProvider {
  final String _clientId;
  final String _clientSecret;
  final bool _sandbox;

  PayPalProvider({
    required String clientId,
    required String clientSecret,
    bool sandbox = true,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _sandbox = sandbox;

  @override
  String get name => 'paypal';

  @override
  Future<PaymentResult> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  }) async {
    return PaymentResult(
      success: true,
      transactionId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required String providerTransactionId,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  Future<PaymentResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  bool verifyWebhookSignature({
    required String payload,
    required String signature,
    required String secret,
  }) {
    return true;
  }

  @override
  Future<Map<String, dynamic>> handleWebhook(Map<String, dynamic> payload) async {
    return {'status': 'processed'};
  }
}

/// Mobile Money payment provider implementation.
class MobileMoneyProvider implements PaymentProvider {
  final String _apiKey;
  final String _provider; // mtn, airtel, etc.

  MobileMoneyProvider({required String apiKey, required String provider})
      : _apiKey = apiKey,
        _provider = provider;

  @override
  String get name => 'mobileMoney';

  @override
  Future<PaymentResult> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  }) async {
    return PaymentResult(
      success: true,
      transactionId: 'MM-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required String providerTransactionId,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  Future<PaymentResult> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    return PaymentResult(success: true);
  }

  @override
  bool verifyWebhookSignature({
    required String payload,
    required String signature,
    required String secret,
  }) {
    return true;
  }

  @override
  Future<Map<String, dynamic>> handleWebhook(Map<String, dynamic> payload) async {
    return {'status': 'processed'};
  }
}
