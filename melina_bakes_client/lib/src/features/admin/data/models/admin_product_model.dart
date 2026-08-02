library;

import '../../domain/entities/admin_product_entity.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminProductModel {
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

  AdminProductModel({
    required this.id, required this.name, required this.sku,
    required this.basePrice, this.salePrice, this.costPrice,
    this.quantityInStock = 0, this.status = ProductStatus.available,
    this.isFeatured = false, this.categoryName,
  });

  factory AdminProductModel.fromJson(Map<String, dynamic> json) => AdminProductModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
        salePrice: (json['salePrice'] as num?)?.toDouble(),
        costPrice: (json['costPrice'] as num?)?.toDouble(),
        quantityInStock: json['quantityInStock'] as int? ?? 0,
        status: _parseStatus(json['status'] as String?),
        isFeatured: json['isFeatured'] as bool? ?? false,
        categoryName: (json['category'] as Map<String, dynamic>?)?['name'] as String?,
      );

  AdminProductEntity toEntity() => AdminProductEntity(
        id: id, name: name, sku: sku, basePrice: basePrice,
        salePrice: salePrice, costPrice: costPrice, quantityInStock: quantityInStock,
        status: status, isFeatured: isFeatured, categoryName: categoryName,
      );
}

ProductStatus _parseStatus(String? v) {
  if (v == null) return ProductStatus.available;
  try { return ProductStatus.values.byName(v); }
  on ArgumentError { return ProductStatus.available; }
}