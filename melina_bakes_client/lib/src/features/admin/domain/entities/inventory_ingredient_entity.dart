/// Admin-view inventory ingredient entity.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class InventoryIngredientEntity extends Equatable {
  final int id;
  final String name;
  final String sku;
  final double quantityInStock;
  final String unitOfMeasure;
  final double reorderLevel;
  final InventoryStatus status;
  final String? supplierName;

  const InventoryIngredientEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantityInStock,
    required this.unitOfMeasure,
    required this.reorderLevel,
    required this.status,
    this.supplierName,
  });

  @override
  List<Object?> get props => [id, name, sku, quantityInStock, unitOfMeasure, reorderLevel, status, supplierName];
}