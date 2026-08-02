
/// Domain entity representing live order tracking information.
///
/// Fetched on demand by tracking number. Provides the current status plus
/// a visual timeline of every lifecycle stage with reachability flags.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import 'order_status_event_entity.dart';

class OrderTrackingEntity extends Equatable {
  /// Customer-facing order number (e.g. "MB-20260801-1001").
  final String orderNumber;

  /// The current, real-time status of the order.
  final OrderStatus currentStatus;

  /// Optional estimated completion time for the active preparation stages.
  final DateTime? estimatedCompletion;

  /// Optional estimated delivery time for the order.
  final DateTime? estimatedDelivery;

  /// Visual lifecycle timeline. Every entry represents one stage of the
  /// order flow, with [OrderStatusEventEntity.completed] indicating
  /// whether that stage has been reached.
  final List<OrderStatusEventEntity> timeline;

  const OrderTrackingEntity({
    required this.orderNumber,
    required this.currentStatus,
    this.estimatedCompletion,
    this.estimatedDelivery,
    this.timeline = const [],
  });

  /// Number of stages already completed in the timeline.
  int get completedCount => timeline.where((e) => e.completed).length;

  /// Overall progress of the order from 0.0 to 1.0.
  double get progress =>
      timeline.isEmpty ? 0.0 : completedCount / timeline.length;

  @override
  List<Object?> get props =>
      [orderNumber, currentStatus, estimatedCompletion, estimatedDelivery, timeline];
}
