library;

import '../../domain/entities/admin_order_list_item_entity.dart';

class AdminOrderListItemModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final double total;
  final String status;
  final String paymentStatus;
  final String createdAt;

  AdminOrderListItemModel({
    required this.id, required this.orderNumber, required this.customerName,
    required this.customerEmail, required this.total, required this.status,
    required this.paymentStatus, required this.createdAt,
  });

  factory AdminOrderListItemModel.fromJson(Map<String, dynamic> json) => AdminOrderListItemModel(
        id: json['id'] as int? ?? 0,
        orderNumber: json['orderNumber'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        customerEmail: json['customerEmail'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? '',
        paymentStatus: json['paymentStatus'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );

  AdminOrderListItemEntity toEntity() => AdminOrderListItemEntity(
        id: id, orderNumber: orderNumber, customerName: customerName,
        customerEmail: customerEmail, total: total, status: status,
        paymentStatus: paymentStatus, createdAt: createdAt,
      );
}