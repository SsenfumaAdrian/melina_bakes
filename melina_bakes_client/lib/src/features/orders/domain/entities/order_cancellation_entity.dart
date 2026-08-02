
/// Domain entity representing the outcome of cancelling an order.
///
/// Returned by the cancel order endpoint. Carries the updated status
/// and any refund information to display to the customer.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class OrderCancellationEntity extends Equatable {
  final int orderId;
  final OrderStatus status;
  final double refundAmount;
  final String refundMethod;
  final DateTime? estimatedRefundDate;

  const OrderCancellationEntity({
    required this.orderId,
    required this.status,
    required this.refundAmount,
    required this.refundMethod,
    this.estimatedRefundDate,
  });

  /// True when the order has been successfully cancelled.
  bool get isCancelled => status == OrderStatus.cancelled;

  /// True when a refund is expected for this cancellation.
  bool get hasRefund => refundAmount > 0;

  @override
  List<Object?> get props =>
      [orderId, status, refundAmount, refundMethod, estimatedRefundDate];
}
