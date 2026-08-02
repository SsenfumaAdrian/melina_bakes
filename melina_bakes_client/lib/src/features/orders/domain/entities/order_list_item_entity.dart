
/// Domain entity representing a lightweight order list row.
///
/// Returned by the list orders endpoint. Contains just enough data
/// to render the order history; the full order is fetched on demand
/// by its `orderNumber`.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class OrderListItemEntity extends Equatable {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double total;
  final int itemCount;
  final DateTime createdAt;

  const OrderListItemEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });

  /// True when the order is in an active (non-terminal) state.
  bool get isActive => status.isActive;

  @override
  List<Object?> get props => [id, orderNumber, status, paymentStatus, total, itemCount, createdAt];
}
