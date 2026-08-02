
/// Data model for serializing live order tracking information.
///
/// Maps the payload of `GET /orders/:number/track`, which includes the
/// current status, estimated timestamps, and the full lifecycle timeline.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/order_tracking_entity.dart';
import 'order_status_event_model.dart';

class OrderTrackingModel {
  final String orderNumber;
  final OrderStatus currentStatus;
  final DateTime? estimatedCompletion;
  final DateTime? estimatedDelivery;
  final List<OrderStatusEventModel> timeline;

  OrderTrackingModel({
    required this.orderNumber,
    required this.currentStatus,
    this.estimatedCompletion,
    this.estimatedDelivery,
    this.timeline = const [],
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];
    return OrderTrackingModel(
      orderNumber: json['orderNumber'] as String? ?? '',
      currentStatus: _parseOrderStatus(json['currentStatus'] as String?),
      estimatedCompletion: _parseDateTime(json['estimatedCompletion'] as String?),
      estimatedDelivery: _parseDateTime(json['estimatedDelivery'] as String?),
      timeline: rawTimeline
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderStatusEventModel.fromJson(e))
          .toList(),
    );
  }

  OrderTrackingEntity toEntity() => OrderTrackingEntity(
        orderNumber: orderNumber,
        currentStatus: currentStatus,
        estimatedCompletion: estimatedCompletion,
        estimatedDelivery: estimatedDelivery,
        timeline: timeline.map((e) => e.toEntity()).toList(),
      );
}

OrderStatus _parseOrderStatus(String? value) {
  if (value == null) return OrderStatus.pending;
  try {
    return OrderStatus.values.byName(value);
  } on ArgumentError {
    return OrderStatus.pending;
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
