library;

import '../../domain/entities/admin_staff_entity.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminStaffModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? department;
  final String? position;
  final bool isActive;

  AdminStaffModel({
    required this.id, required this.email, required this.firstName, required this.lastName,
    required this.role, this.department, this.position, this.isActive = true,
  });

  factory AdminStaffModel.fromJson(Map<String, dynamic> json) => AdminStaffModel(
        id: json['id'] as int? ?? 0,
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        role: _parseRole(json['role'] as String?),
        department: json['department'] as String?,
        position: json['position'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );

  AdminStaffEntity toEntity() => AdminStaffEntity(
        id: id, email: email, firstName: firstName, lastName: lastName,
        role: role, department: department, position: position, isActive: isActive,
      );
}

UserRole _parseRole(String? v) {
  if (v == null) return UserRole.staff;
  try { return UserRole.values.byName(v); } on ArgumentError { return UserRole.staff; }
}