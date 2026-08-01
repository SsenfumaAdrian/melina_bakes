
/// Data model for cart serialization.
library;

import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double subtotal;
  final double? discountAmount;
  final String? couponCode;
  final double taxAmount;
  final double deliveryCharge;
  final double total;
  final int itemCount;

  CartModel({
    required this.id,
    this.items = const [],
    this.subtotal = 0.0,
    this.discountAmount,
    this.couponCode,
    this.taxAmount = 0.0,
    this.deliveryCharge = 0.0,
    this.total = 0.0,
    this.itemCount = 0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      couponCode: json['couponCode'] as String?,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }

  CartEntity toEntity() => CartEntity(
    id: id,
    items: items.map((i) => i.toEntity()).toList(),
    subtotal: subtotal,
    discountAmount: discountAmount,
    couponCode: couponCode,
    taxAmount: taxAmount,
    deliveryCharge: deliveryCharge,
    total: total,
    itemCount: itemCount,
  );
}
