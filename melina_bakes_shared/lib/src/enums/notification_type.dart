/// Types of notifications sent to users.
enum NotificationType {
  /// Order status update.
  orderUpdate,

  /// Promotional offer.
  promotion,

  /// Inventory alert.
  inventoryAlert,

  /// Payment confirmation.
  payment,

  /// General system notification.
  system,

  /// Account security alert.
  security;

  String get displayName {
    return switch (this) {
      NotificationType.orderUpdate => 'Order Update',
      NotificationType.promotion => 'Promotion',
      NotificationType.inventoryAlert => 'Inventory Alert',
      NotificationType.payment => 'Payment',
      NotificationType.system => 'System',
      NotificationType.security => 'Security',
    };
  }
}
