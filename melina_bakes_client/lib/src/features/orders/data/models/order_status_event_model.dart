
/// Data model for serializing a single entry in the order status history.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/order_status_event_entity.dart';

class OrderStatusEventModel {
  final OrderStatus status;
  final String? label;
  final DateTime? timestamp;
  final String? note;
  final bool completed;

  OrderStatusEventModel({
    required this.status,
    this.label,
    this.timestamp,
    this.note,
    this.completed = false,
  });

  factory OrderStatusEventModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;
    final status = _parseOrderStatus(rawStatus);

    // The detail endpoint exposes `timestamp` as an ISO string.
    // The tracking endpoint exposes the human-friendly `time` instead,
    // which has no year/date context, so it is not parsed into a DateTime.
    final rawTime = json['time'] as String?;
    final timestamp = _parseDateTime(json['timestamp'] as String?);
    final note = json['note'] as String? ?? (rawTime != null ? 'Updated at $rawTime' : null);

    return OrderStatusEventModel(
      status: status,
      label: json['label'] as String?,
      timestamp: timestamp,
      note: note,
      completed: json['completed'] as bool? ?? false,
    );
  }

  OrderStatusEventEntity toEntity() => OrderStatusEventEntity(
        status: status,
        label: label,
        timestamp: timestamp,
        note: note,
        completed: completed,
      );
}

/// Safely parses an [OrderStatus] from its enum name. Falls back to
/// [OrderStatus.pending] when the server sends an unknown value, so the
/// UI degrades gracefully instead of crashing.
OrderStatus _parseOrderStatus(String? value) {
  if (value == null) return OrderStatus.pending;
  try {
    return OrderStatus.values.byName(value);
  } on ArgumentError {
    return OrderStatus.pending;
  }
}

/// Parses an ISO-8601 timestamp into a [DateTime], returning null on
/// empty or malformed input.
DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
