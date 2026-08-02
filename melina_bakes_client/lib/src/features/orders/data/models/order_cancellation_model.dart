
/// Data model for serializing the cancellation outcome of an order.
///
/// Maps the payload of `POST /orders/:id/cancel`, which includes the
/// updated status, refund amount, refund method, and the estimated
/// refund date.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/order_cancellation_entity.dart';

class OrderCancellationModel {
  final int orderId;
  final OrderStatus status;
  final double refundAmount;
  final String refundMethod;
  final DateTime? estimatedRefundDate;

  OrderCancellationModel({
    required this.orderId,
    required this.status,
    required this.refundAmount,
    required this.refundMethod,
    this.estimatedRefundDate,
  });

  factory OrderCancellationModel.fromJson(Map<String, dynamic> json) {
    return OrderCancellationModel(
      orderId: json['orderId'] as int? ?? 0,
      status: _parseOrderStatus(json['status'] as String?),
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      refundMethod: json['refundMethod'] as String? ?? 'original_payment',
      estimatedRefundDate: _parseDateTime(json['estimatedRefundDate'] as String?),
    );
  }

  OrderCancellationEntity toEntity() => OrderCancellationEntity(
        orderId: orderId,
        status: status,
        refundAmount: refundAmount,
        refundMethod: refundMethod,
        estimatedRefundDate: estimatedRefundDate,
      );
}

OrderStatus _parseOrderStatus(String? value) {
  if (value == null) return OrderStatus.cancelled;
  try {
    return OrderStatus.values.byName(value);
  } on ArgumentError {
    return OrderStatus.cancelled;
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
