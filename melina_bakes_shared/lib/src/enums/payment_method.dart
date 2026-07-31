/// Supported payment methods for Melina Bakes.
enum PaymentMethod {
  /// Credit/Debit card via Stripe.
  stripe,

  /// Flutterwave payment gateway.
  flutterwave,

  /// PayPal payment.
  paypal,

  /// Mobile money (MTN, Airtel, etc.).
  mobileMoney,

  /// Cash on delivery.
  cashOnDelivery,

  /// Bank transfer.
  bankTransfer;

  String get displayName {
    return switch (this) {
      PaymentMethod.stripe => 'Credit/Debit Card',
      PaymentMethod.flutterwave => 'Flutterwave',
      PaymentMethod.paypal => 'PayPal',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.cashOnDelivery => 'Cash on Delivery',
      PaymentMethod.bankTransfer => 'Bank Transfer',
    };
  }

  /// Returns true if this method requires online payment processing.
  bool get isOnline => 
      this != PaymentMethod.cashOnDelivery && 
      this != PaymentMethod.bankTransfer;
}
