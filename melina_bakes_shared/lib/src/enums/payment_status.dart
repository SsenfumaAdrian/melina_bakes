/// Represents the payment state of an order or transaction.
enum PaymentStatus {
  /// Payment not yet initiated.
  pending,

  /// Payment is being processed.
  processing,

  /// Payment completed successfully.
  completed,

  /// Payment failed.
  failed,

  /// Payment was refunded.
  refunded,

  /// Partial refund issued.
  partiallyRefunded;

  /// Returns true if the payment is in a terminal success state.
  bool get isSuccessful => this == PaymentStatus.completed;

  /// Returns true if the payment can be retried.
  bool get canRetry => 
      this == PaymentStatus.pending || 
      this == PaymentStatus.failed;

  String get displayName {
    return switch (this) {
      PaymentStatus.pending => 'Pending',
      PaymentStatus.processing => 'Processing',
      PaymentStatus.completed => 'Completed',
      PaymentStatus.failed => 'Failed',
      PaymentStatus.refunded => 'Refunded',
      PaymentStatus.partiallyRefunded => 'Partially Refunded',
    };
  }
}
