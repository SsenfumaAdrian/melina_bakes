
/// Data model for serializing an order line item from the API.
library;

import '../../domain/entities/order_item_entity.dart';

class OrderItemModel {
  final int? id;
  final int productId;
  final String productName;
  final String? productSku;
  final String? productImageUrl;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? specialInstructions;

  OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      productSku: json['productSku'] as String?,
      productImageUrl: json['productImageUrl'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
        id: id,
        productId: productId,
        productName: productName,
        productSku: productSku,
        productImageUrl: productImageUrl,
        unitPrice: unitPrice,
        quantity: quantity,
        totalPrice: totalPrice,
        specialInstructions: specialInstructions,
      );
}
