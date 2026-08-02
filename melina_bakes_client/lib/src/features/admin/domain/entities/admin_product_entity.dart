/// Admin-view product entity with cost-price and extra fields.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminProductEntity extends Equatable {
  final int id;
  final String name;
  final String sku;
  final double basePrice;
  final double? salePrice;
  final double? costPrice;
  final int quantityInStock;
  final ProductStatus status;
  final bool isFeatured;
  final String? categoryName;

  const AdminProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.basePrice,
    this.salePrice,
    this.costPrice,
    this.quantityInStock = 0,
    this.status = ProductStatus.available,
    this.isFeatured = false,
    this.categoryName,
  });

  /// Margin percentage based on cost price.
  double get marginPercent {
    if (costPrice == null || costPrice == 0) return 0;
    return (((salePrice ?? basePrice) - costPrice!) / costPrice!) * 100;
  }

  @override
  List<Object?> get props => [id, name, sku, basePrice, salePrice, costPrice, quantityInStock, status, isFeatured, categoryName];
}