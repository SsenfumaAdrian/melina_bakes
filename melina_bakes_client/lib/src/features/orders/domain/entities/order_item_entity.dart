
/// Domain entity representing a line item within an order.
///
/// A snapshot of a product at the moment of purchase, capturing the
/// name, image, and unit price the customer paid. This decouples the
/// historical record from live product data.
library;

import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  /// Optional server-assigned identifier.
  final int? id;

  /// Identifier of the purchased product.
  final int productId;

  /// Product name captured at purchase time.
  final String productName;

  /// Optional product SKU captured at purchase time.
  final String? productSku;

  /// Optional primary image URL for the product.
  final String? productImageUrl;

  /// Unit price the customer paid for a single unit.
  final double unitPrice;

  /// Number of units purchased.
  final int quantity;

  /// Total price for this line item (`unitPrice * quantity`).
  final double totalPrice;

  /// Optional special instructions provided by the customer for this item.
  final String? specialInstructions;

  const OrderItemEntity({
    this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions,
  });

  /// Returns true when the customer attached per-item instructions.
  bool get hasSpecialInstructions =>
      specialInstructions != null && specialInstructions!.trim().isNotEmpty;

  OrderItemEntity copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productSku,
    String? productImageUrl,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    String? specialInstructions,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productSku,
        productImageUrl,
        unitPrice,
        quantity,
        totalPrice,
        specialInstructions,
      ];
}
