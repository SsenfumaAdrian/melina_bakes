/// Admin-order list row entity (lighter than customer OrderListItemEntity).
library;

import 'package:equatable/equatable.dart';

class AdminOrderListItemEntity extends Equatable {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final double total;
  final String status;
  final String paymentStatus;
  final String createdAt;

  const AdminOrderListItemEntity({
    required this.id, required this.orderNumber, required this.customerName,
    required this.customerEmail, required this.total, required this.status,
    required this.paymentStatus, required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderNumber, customerName, customerEmail, total, status, paymentStatus, createdAt];
}