/// Represents the lifecycle stages of a bakery order.
///
/// Orders progress through these states in a mostly linear fashion,
/// though [cancelled] can occur from any active state.
enum OrderStatus {
  /// Order created, awaiting payment or confirmation.
  pending,

  /// Payment received, order confirmed by system.
  confirmed,

  /// Bakery staff has started preparing the order.
  preparing,

  /// Items are currently being baked.
  baking,

  /// Baking complete, items cooling and being packaged.
  ready,

  /// Order handed to delivery service or ready for pickup.
  outForDelivery,

  /// Order successfully delivered or picked up.
  completed,

  /// Order cancelled by customer or system.
  cancelled;

  /// Returns true if the order is in an active (non-terminal) state.
  bool get isActive => 
      this != OrderStatus.completed && 
      this != OrderStatus.cancelled;

  /// Returns true if the order can be cancelled.
  bool get canCancel => 
      this == OrderStatus.pending || 
      this == OrderStatus.confirmed;

  /// Returns the display label for this status.
  String get displayName {
    return switch (this) {
      OrderStatus.pending => 'Pending',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.baking => 'Baking',
      OrderStatus.ready => 'Ready',
      OrderStatus.outForDelivery => 'Out for Delivery',
      OrderStatus.completed => 'Completed',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  /// Returns a color hint for UI representation.
  String get colorHint {
    return switch (this) {
      OrderStatus.pending => 'orange',
      OrderStatus.confirmed => 'blue',
      OrderStatus.preparing => 'indigo',
      OrderStatus.baking => 'amber',
      OrderStatus.ready => 'green',
      OrderStatus.outForDelivery => 'teal',
      OrderStatus.completed => 'emerald',
      OrderStatus.cancelled => 'red',
    };
  }
}
