
/// Domain entity representing an authenticated user.
///
/// This is the canonical user representation used throughout
/// the presentation layer. Decoupled from data layer models.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

/// Authenticated user entity.
class UserEntity extends Equatable {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.isEmailVerified = false,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  /// Returns the user's display name (first + last, or email fallback).
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return email.split('@').first;
  }

  /// Returns the user's initials for avatar placeholders.
  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      final lastInitial = lastName != null && lastName!.isNotEmpty
          ? lastName![0]
          : '';
      return '${firstName![0]}$lastInitial'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        avatarUrl,
        role,
        isEmailVerified,
        isActive,
        lastLoginAt,
        createdAt,
      ];
}
