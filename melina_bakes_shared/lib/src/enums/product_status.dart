/// Availability status of a bakery product.
enum ProductStatus {
  /// Product is available for purchase.
  available,

  /// Product is out of stock.
  outOfStock,

  /// Product is discontinued.
  discontinued,

  /// Product is coming soon.
  comingSoon;

  bool get isAvailable => this == ProductStatus.available;

  String get displayName {
    return switch (this) {
      ProductStatus.available => 'Available',
      ProductStatus.outOfStock => 'Out of Stock',
      ProductStatus.discontinued => 'Discontinued',
      ProductStatus.comingSoon => 'Coming Soon',
    };
  }
}
