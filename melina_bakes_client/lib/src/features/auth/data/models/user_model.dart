
/// Data model for user serialization/deserialization.
///
/// Maps between JSON and the domain [UserEntity].
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final bool isEmailVerified;
  final bool isActive;
  final String? lastLoginAt;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.isEmailVerified = false,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'customer',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] as String?,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt,
      'createdAt': createdAt,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      role: UserRole.values.byName(role),
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      lastLoginAt: lastLoginAt != null ? DateTime.tryParse(lastLoginAt!) : null,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
