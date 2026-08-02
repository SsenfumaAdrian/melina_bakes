
/// Data model for serializing a lightweight order list row.
library;

import '../../domain/entities/order_list_item_entity.dart';

class OrderListItemModel {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double total;
  final int itemCount;
  final DateTime createdAt;

  const OrderListItemModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });

  factory OrderListItemModel.fromJson(Map<String, dynamic> json) {
    return OrderListItemModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: _parseOrderStatus(json['status'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['createdAt'] as String?) ?? DateTime.now().toUtc(),
    );
  }

  OrderListItemEntity toEntity() => OrderListItemEntity(
        id: id,
        orderNumber: orderNumber,
        status: status,
        paymentStatus: paymentStatus,
        total: total,
        itemCount: itemCount,
        createdAt: createdAt,
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

PaymentStatus _parsePaymentStatus(String? value) {
  if (value == null) return PaymentStatus.pending;
  try {
    return PaymentStatus.values.byName(value);
  } on ArgumentError {
    return PaymentStatus.pending;
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
