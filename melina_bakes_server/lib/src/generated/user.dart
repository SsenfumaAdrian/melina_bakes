/// GENERATED CODE - DO NOT MODIFY BY HAND
/// Generated from protocol/user.yaml
/// 
/// Represents a user account in the Melina Bakes system.

// ignore_for_file: public_member_api_docs

import 'package:serverpod/serverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class User extends TableRow {
  @override
  String get tableName => 'users';

  int? id;
  String email;
  String passwordHash;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? avatarUrl;
  UserRole role;
  bool isEmailVerified;
  bool isActive;
  int failedLoginAttempts;
  DateTime? lockedUntil;
  DateTime? lastLoginAt;
  String? lastLoginIp;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.isEmailVerified = false,
    this.isActive = true,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.lastLoginAt,
    this.lastLoginIp,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'passwordHash': passwordHash,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'isEmailVerified': isEmailVerified,
        'isActive': isActive,
        'failedLoginAttempts': failedLoginAttempts,
        'lockedUntil': lockedUntil?.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'lastLoginIp': lastLoginIp,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        role: UserRole.values.byName(json['role'] as String),
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
        lockedUntil: json['lockedUntil'] != null
            ? DateTime.parse(json['lockedUntil'] as String)
            : null,
        lastLoginAt: json['lastLoginAt'] != null
            ? DateTime.parse(json['lastLoginAt'] as String)
            : null,
        lastLoginIp: json['lastLoginIp'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );

  /// Returns the user's full name or email if names are not set.
  String get displayName {
    if (firstName != null && lastName != null) {
      return '\$firstName \$lastName';
    }
    if (firstName != null) return firstName!;
    return email;
  }

  /// Returns true if the user account is currently locked.
  bool get isLocked {
    if (lockedUntil == null) return false;
    return lockedUntil!.isAfter(DateTime.now());
  }

  /// Returns true if the user has admin privileges.
  bool get isAdmin => role == UserRole.admin;

  /// Returns true if the user has manager or admin privileges.
  bool get isManagerOrAbove =>
      role == UserRole.admin || role == UserRole.manager;

  /// Returns true if the user is staff or above.
  bool get isStaffOrAbove =>
      role == UserRole.admin ||
      role == UserRole.manager ||
      role == UserRole.staff;

  @override
  String toString() =>
      'User(id: \$id, email: \$email, role: \$role, active: \$isActive)';
}

/// Database table definition for [User].
class UserTable extends Table {
  UserTable() : super(tableName: 'users');

  final email = ColumnString('email');
  final passwordHash = ColumnString('password_hash');
  final firstName = ColumnString('first_name');
  final lastName = ColumnString('last_name');
  final phoneNumber = ColumnString('phone_number');
  final avatarUrl = ColumnString('avatar_url');
  final role = ColumnString('role');
  final isEmailVerified = ColumnBool('is_email_verified');
  final isActive = ColumnBool('is_active');
  final failedLoginAttempts = ColumnInt('failed_login_attempts');
  final lockedUntil = ColumnDateTime('locked_until');
  final lastLoginAt = ColumnDateTime('last_login_at');
  final lastLoginIp = ColumnString('last_login_ip');
  final createdAt = ColumnDateTime('created_at');
  final updatedAt = ColumnDateTime('updated_at');
  final deletedAt = ColumnDateTime('deleted_at');

  @override
  List<Column> get columns => [
        email,
        passwordHash,
        firstName,
        lastName,
        phoneNumber,
        avatarUrl,
        role,
        isEmailVerified,
        isActive,
        failedLoginAttempts,
        lockedUntil,
        lastLoginAt,
        lastLoginIp,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
