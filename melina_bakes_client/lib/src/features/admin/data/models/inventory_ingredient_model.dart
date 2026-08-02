library;

import '../../domain/entities/inventory_ingredient_entity.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class InventoryIngredientModel {
  final int id;
  final String name;
  final String sku;
  final double quantityInStock;
  final String unitOfMeasure;
  final double reorderLevel;
  final InventoryStatus status;
  final String? supplierName;

  InventoryIngredientModel({
    required this.id, required this.name, required this.sku,
    required this.quantityInStock, required this.unitOfMeasure,
    required this.reorderLevel, required this.status, this.supplierName,
  });

  factory InventoryIngredientModel.fromJson(Map<String, dynamic> json) => InventoryIngredientModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        quantityInStock: (json['quantityInStock'] as num?)?.toDouble() ?? 0,
        unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
        reorderLevel: (json['reorderLevel'] as num?)?.toDouble() ?? 0,
        status: _parseStatus(json['status'] as String?),
        supplierName: (json['supplier'] as Map<String, dynamic>?)?['name'] as String?,
      );

  InventoryIngredientEntity toEntity() => InventoryIngredientEntity(
        id: id, name: name, sku: sku, quantityInStock: quantityInStock,
        unitOfMeasure: unitOfMeasure, reorderLevel: reorderLevel, status: status,
        supplierName: supplierName,
      );
}

InventoryStatus _parseStatus(String? v) {
  if (v == null) return InventoryStatus.inStock;
  try { return InventoryStatus.values.byName(v); } on ArgumentError { return InventoryStatus.inStock; }
}