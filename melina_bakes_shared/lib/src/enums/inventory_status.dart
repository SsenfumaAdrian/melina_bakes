/// Stock level status for inventory tracking.
enum InventoryStatus {
  /// Stock level is healthy.
  inStock,

  /// Stock level is below reorder threshold.
  lowStock,

  /// Stock level is at or below critical threshold.
  critical,

  /// Item is out of stock.
  outOfStock;

  bool get needsReorder => 
      this == InventoryStatus.lowStock || 
      this == InventoryStatus.critical;

  String get displayName {
    return switch (this) {
      InventoryStatus.inStock => 'In Stock',
      InventoryStatus.lowStock => 'Low Stock',
      InventoryStatus.critical => 'Critical',
      InventoryStatus.outOfStock => 'Out of Stock',
    };
  }
}
