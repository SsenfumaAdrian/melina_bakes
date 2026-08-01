
/// Data model for cart item serialization.
library;

import '../../domain/entities/cart_item_entity.dart';

class CartItemModel {
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

  CartItemModel({
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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      productSlug: json['productSlug'] as String? ?? '',
      productImageUrl: json['productImageUrl'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }

  CartItemEntity toEntity() => CartItemEntity(
    id: id, productId: productId, productName: productName,
    productSlug: productSlug, productImageUrl: productImageUrl,
    unitPrice: unitPrice, salePrice: salePrice, quantity: quantity,
    subtotal: subtotal, attributes: attributes,
  );
}
