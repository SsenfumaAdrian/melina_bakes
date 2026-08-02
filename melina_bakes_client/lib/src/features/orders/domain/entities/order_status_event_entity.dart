
/// Domain entity representing a single entry in an order's status history.
///
/// Used both for the chronological status timeline displayed on the
/// detail screen and for the live tracking timeline.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class OrderStatusEventEntity extends Equatable {
  /// The status this event transitioned the order into.
  final OrderStatus status;

  /// Optional human-friendly label for the timeline (e.g. "Baking").
  final String? label;

  /// UTC timestamp at which the transition occurred, if known.
  final DateTime? timestamp;

  /// Optional note describing why the transition happened.
  final String? note;

  /// True when this stage has been reached/completed.
  final bool completed;

  const OrderStatusEventEntity({
    required this.status,
    this.label,
    this.timestamp,
    this.note,
    this.completed = false,
  });

  /// Returns the display label, falling back to the status's display name.
  String get displayLabel => label ?? status.displayName;

  @override
  List<Object?> get props => [status, label, timestamp, note, completed];
}
