library;

import '../../domain/entities/admin_customer_entity.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminCustomerModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final UserRole role;
  final bool isActive;
  final int totalOrders;
  final double totalSpent;
  final String? createdAt;

  AdminCustomerModel({
    required this.id, required this.email, this.firstName, this.lastName,
    this.phoneNumber, this.role = UserRole.customer, this.isActive = true,
    this.totalOrders = 0, this.totalSpent = 0, this.createdAt,
  });

  factory AdminCustomerModel.fromJson(Map<String, dynamic> json) => AdminCustomerModel(
        id: json['id'] as int? ?? 0,
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        role: _parseRole(json['role'] as String?),
        isActive: json['isActive'] as bool? ?? true,
        totalOrders: json['totalOrders'] as int? ?? 0,
        totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
        createdAt: json['createdAt'] as String?,
      );

  AdminCustomerEntity toEntity() => AdminCustomerEntity(
        id: id, email: email, firstName: firstName, lastName: lastName,
        phoneNumber: phoneNumber, role: role, isActive: isActive,
        totalOrders: totalOrders, totalSpent: totalSpent, createdAt: createdAt,
      );
}

UserRole _parseRole(String? v) {
  if (v == null) return UserRole.customer;
  try { return UserRole.values.byName(v); } on ArgumentError { return UserRole.customer; }
}