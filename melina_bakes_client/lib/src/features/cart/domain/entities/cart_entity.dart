
/// Domain entity representing the entire shopping cart.
library;

import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final int id;
  final List<CartItemEntity> items;
  final double subtotal;
  final double? discountAmount;
  final String? couponCode;
  final double taxAmount;
  final double deliveryCharge;
  final double total;
  final int itemCount;

  const CartEntity({
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

  /// Returns the total number of individual items (sum of quantities).
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Returns true if the cart has items.
  bool get isEmpty => items.isEmpty;

  /// Returns true if a coupon has been applied.
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  CartEntity copyWith({
    int? id,
    List<CartItemEntity>? items,
    double? subtotal,
    double? discountAmount,
    String? couponCode,
    double? taxAmount,
    double? deliveryCharge,
    double? total,
    int? itemCount,
  }) {
    return CartEntity(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  List<Object?> get props => [id, items, subtotal, discountAmount, couponCode, taxAmount, deliveryCharge, total, itemCount];
}
