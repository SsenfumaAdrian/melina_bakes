/// Defines the roles available in the Melina Bakes system.
///
/// Roles determine access permissions across the platform.
/// The hierarchy is: Customer < Staff < Manager < Admin.
enum UserRole {
  /// System administrator with full access.
  admin,

  /// Bakery manager with operational oversight.
  manager,

  /// Staff member with limited operational access.
  staff,

  /// Registered customer with shopping capabilities.
  customer,

  /// Unauthenticated visitor.
  guest;

  /// Checks if this role has at least the permissions of [other].
  bool hasPermission(UserRole other) {
    final values = UserRole.values;
    return values.indexOf(this) <= values.indexOf(other);
  }

  /// Returns true if this role can access admin features.
  bool get isAdmin => this == UserRole.admin;

  /// Returns true if this role can access management features.
  bool get isManagerOrAbove => 
      this == UserRole.admin || this == UserRole.manager;

  /// Returns true if this role is staff or above.
  bool get isStaffOrAbove => 
      this == UserRole.admin || 
      this == UserRole.manager || 
      this == UserRole.staff;

  /// Returns the display name for this role.
  String get displayName {
    return switch (this) {
      UserRole.admin => 'Administrator',
      UserRole.manager => 'Manager',
      UserRole.staff => 'Staff',
      UserRole.customer => 'Customer',
      UserRole.guest => 'Guest',
    };
  }
}
