
/// Domain entity representing a customer order.
///
/// Contains the full pricing breakdown, the list of purchased items, the
/// delivery address snapshot, and the chronological status history. This
/// entity is the single source the presentation layer consumes for both
/// the order detail and the order tracking screens.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import 'order_address_entity.dart';
import 'order_item_entity.dart';
import 'order_status_event_entity.dart';

class OrderEntity extends Equatable {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentStatus paymentStatus;

  /// Pricing breakdown in the customer's currency.
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double deliveryCharge;
  final double total;

  /// Optional coupon applied at checkout.
  final String? couponCode;
  final double couponDiscount;

  /// Snapshot of the customer's identity at purchase time.
  final String customerName;
  final String customerEmail;
  final String? customerPhone;

  /// Delivery address captured at purchase, or null for pickup orders.
  final OrderAddressEntity? deliveryAddress;

  /// Delivery method token (e.g. "standard", "pickup").
  final String deliveryMethod;

  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredAt;

  /// Free-text note provided by the customer at checkout.
  final String? customerNotes;

  /// Internal note set by bakery staff.
  final String? staffNotes;

  /// Line items belonging to this order.
  final List<OrderItemEntity> items;

  /// Chronological status history.
  final List<OrderStatusEventEntity> statusHistory;

  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
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

  /// Sum of quantities across all line items.
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// True when the order is in any non-terminal, active state.
  bool get isActive => status.isActive;

  /// True when the customer can still cancel this order.
  bool get canCancel => status.canCancel;

  /// True when a coupon was applied at checkout.
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// True when the order has been fully dispatched to the customer.
  bool get isDelivered => status == OrderStatus.completed;

  /// The most recent status event in the history, or null when empty.
  OrderStatusEventEntity? get latestEvent =>
      statusHistory.isNotEmpty ? statusHistory.last : null;

  OrderEntity copyWith({
    int? id,
    String? orderNumber,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? deliveryCharge,
    double? total,
    String? couponCode,
    double? couponDiscount,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    OrderAddressEntity? deliveryAddress,
    String? deliveryMethod,
    DateTime? estimatedDeliveryDate,
    DateTime? deliveredAt,
    String? customerNotes,
    String? staffNotes,
    List<OrderItemEntity>? items,
    List<OrderStatusEventEntity>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      customerNotes: customerNotes ?? this.customerNotes,
      staffNotes: staffNotes ?? this.staffNotes,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, orderNumber, status, paymentStatus, subtotal, discountAmount,
        taxAmount, deliveryCharge, total, couponCode, couponDiscount,
        customerName, customerEmail, customerPhone, deliveryAddress,
        deliveryMethod, estimatedDeliveryDate, deliveredAt, customerNotes,
        staffNotes, items, statusHistory, createdAt, updatedAt,
      ];
}
