
/// Domain entity representing an item in the shopping cart.
library;

import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String productSlug;
  final String? productImageUrl;
  final double unitPrice;
  final double? salePrice;
  final int quantity;
  final double subtotal;
  final Map<String, dynamic>? attributes;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSlug,
    this.productImageUrl,
    required this.unitPrice,
    this.salePrice,
    required this.quantity,
    required this.subtotal,
    this.attributes,
  });

  /// Returns the effective unit price.
  double get price => salePrice ?? unitPrice;

  /// Calculates the subtotal based on current quantity.
  double get calculatedSubtotal => price * quantity;

  /// Returns true if this item has a sale price.
  bool get isOnSale => salePrice != null && salePrice! < unitPrice;

  CartItemEntity copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productSlug,
    String? productImageUrl,
    double? unitPrice,
    double? salePrice,
    int? quantity,
    double? subtotal,
    Map<String, dynamic>? attributes,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSlug: productSlug ?? this.productSlug,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  List<Object?> get props => [id, productId, productName, productSlug, productImageUrl, unitPrice, salePrice, quantity, subtotal, attributes];
}
