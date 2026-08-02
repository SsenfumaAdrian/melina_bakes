
/// Data model for serializing a full order (detail endpoint) from the API.
///
/// Handles the complete order payload including items, status history,
/// and the delivery address snapshot. Mirrors the structure returned by
/// `GET /orders/:number`.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/order_entity.dart';
import 'order_address_model.dart';
import 'order_item_model.dart';
import 'order_status_event_model.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double deliveryCharge;
  final double total;
  final String? couponCode;
  final double couponDiscount;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final OrderAddressModel? deliveryAddress;
  final String deliveryMethod;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredAt;
  final String? customerNotes;
  final String? staffNotes;
  final List<OrderItemModel> items;
  final List<OrderStatusEventModel> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.deliveryCharge = 0.0,
    this.total = 0.0,
    this.couponCode,
    this.couponDiscount = 0.0,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryMethod = 'standard',
    this.estimatedDeliveryDate,
    this.deliveredAt,
    this.customerNotes,
    this.staffNotes,
    this.items = const [],
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawHistory = json['statusHistory'] as List<dynamic>? ?? [];
    final rawAddress = json['deliveryAddress'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: _parseOrderStatus(json['status'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'] as String?,
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerPhone: json['customerPhone'] as String?,
      deliveryAddress:
          rawAddress != null ? OrderAddressModel.fromJson(rawAddress) : null,
      deliveryMethod: json['deliveryMethod'] as String? ?? 'standard',
      estimatedDeliveryDate: _parseDateTime(json['estimatedDeliveryDate'] as String?),
      deliveredAt: _parseDateTime(json['deliveredAt'] as String?),
      customerNotes: json['customerNotes'] as String?,
      staffNotes: json['staffNotes'] as String?,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      statusHistory: rawHistory
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderStatusEventModel.fromJson(e))
          .toList(),
      createdAt: _parseDateTime(json['createdAt'] as String?) ?? DateTime.now().toUtc(),
      updatedAt: _parseDateTime(json['updatedAt'] as String?) ?? DateTime.now().toUtc(),
    );
  }

  OrderEntity toEntity() => OrderEntity(
        id: id,
        orderNumber: orderNumber,
        status: status,
        paymentStatus: paymentStatus,
        subtotal: subtotal,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        deliveryCharge: deliveryCharge,
        total: total,
        couponCode: couponCode,
        couponDiscount: couponDiscount,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        deliveryAddress: deliveryAddress?.toEntity(),
        deliveryMethod: deliveryMethod,
        estimatedDeliveryDate: estimatedDeliveryDate,
        deliveredAt: deliveredAt,
        customerNotes: customerNotes,
        staffNotes: staffNotes,
        items: items.map((e) => e.toEntity()).toList(),
        statusHistory: statusHistory.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
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
