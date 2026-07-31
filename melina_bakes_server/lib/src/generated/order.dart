/// GENERATED CODE - DO NOT MODIFY BY HAND
/// Generated from protocol/order.yaml

// ignore_for_file: public_member_api_docs

import 'package:serverpod/serverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class Order extends TableRow {
  @override
  String get tableName => 'orders';

  int? id;
  int userId;
  int? cartId;
  String orderNumber;
  OrderStatus status;
  PaymentStatus paymentStatus;
  double subtotal;
  double discountAmount;
  double taxAmount;
  double deliveryCharge;
  double total;
  String? couponCode;
  double couponDiscount;
  int? deliveryAddressId;
  String deliveryMethod;
  DateTime? estimatedDeliveryDate;
  DateTime? deliveredAt;
  String customerName;
  String customerEmail;
  String? customerPhone;
  String? customerNotes;
  String? staffNotes;
  DateTime createdAt;
  DateTime updatedAt;

  Order({
    this.id,
    required this.userId,
    this.cartId,
    required this.orderNumber,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.deliveryCharge = 0.0,
    this.total = 0.0,
    this.couponCode,
    this.couponDiscount = 0.0,
    this.deliveryAddressId,
    this.deliveryMethod = 'standard',
    this.estimatedDeliveryDate,
    this.deliveredAt,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    this.customerNotes,
    this.staffNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'cartId': cartId,
        'orderNumber': orderNumber,
        'status': status.name,
        'paymentStatus': paymentStatus.name,
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'taxAmount': taxAmount,
        'deliveryCharge': deliveryCharge,
        'total': total,
        'couponCode': couponCode,
        'couponDiscount': couponDiscount,
        'deliveryAddressId': deliveryAddressId,
        'deliveryMethod': deliveryMethod,
        'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'customerNotes': customerNotes,
        'staffNotes': staffNotes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        cartId: json['cartId'] as int?,
        orderNumber: json['orderNumber'] as String,
        status: OrderStatus.values.byName(json['status'] as String),
        paymentStatus:
            PaymentStatus.values.byName(json['paymentStatus'] as String),
        subtotal: (json['subtotal'] as num).toDouble(),
        discountAmount: (json['discountAmount'] as num).toDouble(),
        taxAmount: (json['taxAmount'] as num).toDouble(),
        deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        couponCode: json['couponCode'] as String?,
        couponDiscount: (json['couponDiscount'] as num).toDouble(),
        deliveryAddressId: json['deliveryAddressId'] as int?,
        deliveryMethod: json['deliveryMethod'] as String,
        estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
            ? DateTime.parse(json['estimatedDeliveryDate'] as String)
            : null,
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.parse(json['deliveredAt'] as String)
            : null,
        customerName: json['customerName'] as String,
        customerEmail: json['customerEmail'] as String,
        customerPhone: json['customerPhone'] as String?,
        customerNotes: json['customerNotes'] as String?,
        staffNotes: json['staffNotes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Returns true if the order is in an active state.
  bool get isActive => status.isActive;

  /// Returns true if the order can be cancelled.
  bool get canCancel => status.canCancel;

  /// Returns the formatted order number for display.
  String get displayOrderNumber => '#\$orderNumber';

  @override
  String toString() =>
      'Order(id: \$id, number: \$orderNumber, status: \$status, total: \$total)';
}

class OrderTable extends Table {
  OrderTable() : super(tableName: 'orders');

  final userId = ColumnInt('user_id');
  final cartId = ColumnInt('cart_id');
  final orderNumber = ColumnString('order_number');
  final status = ColumnString('status');
  final paymentStatus = ColumnString('payment_status');
  final subtotal = ColumnDouble('subtotal');
  final discountAmount = ColumnDouble('discount_amount');
  final taxAmount = ColumnDouble('tax_amount');
  final deliveryCharge = ColumnDouble('delivery_charge');
  final total = ColumnDouble('total');
  final couponCode = ColumnString('coupon_code');
  final couponDiscount = ColumnDouble('coupon_discount');
  final deliveryAddressId = ColumnInt('delivery_address_id');
  final deliveryMethod = ColumnString('delivery_method');
  final estimatedDeliveryDate = ColumnDateTime('estimated_delivery_date');
  final deliveredAt = ColumnDateTime('delivered_at');
  final customerName = ColumnString('customer_name');
  final customerEmail = ColumnString('customer_email');
  final customerPhone = ColumnString('customer_phone');
  final customerNotes = ColumnString('customer_notes');
  final staffNotes = ColumnString('staff_notes');
  final createdAt = ColumnDateTime('created_at');
  final updatedAt = ColumnDateTime('updated_at');

  @override
  List<Column> get columns => [
        userId, cartId, orderNumber, status, paymentStatus,
        subtotal, discountAmount, taxAmount, deliveryCharge, total,
        couponCode, couponDiscount, deliveryAddressId, deliveryMethod,
        estimatedDeliveryDate, deliveredAt, customerName, customerEmail,
        customerPhone, customerNotes, staffNotes, createdAt, updatedAt,
      ];
}
