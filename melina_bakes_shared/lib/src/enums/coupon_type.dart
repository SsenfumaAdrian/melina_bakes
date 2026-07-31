/// Types of discount coupons.
enum CouponType {
  /// Percentage discount (e.g., 20% off).
  percentage,

  /// Fixed amount discount (e.g., $10 off).
  fixedAmount,

  /// Free shipping.
  freeShipping,

  /// Buy X get Y free.
  buyXGetY;

  String get displayName {
    return switch (this) {
      CouponType.percentage => 'Percentage Off',
      CouponType.fixedAmount => 'Fixed Amount Off',
      CouponType.freeShipping => 'Free Shipping',
      CouponType.buyXGetY => 'Buy X Get Y',
    };
  }
}
