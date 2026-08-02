/// Admin-view staff member entity.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminStaffEntity extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? department;
  final String? position;
  final bool isActive;

  const AdminStaffEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.department,
    this.position,
    this.isActive = true,
  });

  String get displayName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  @override
  List<Object?> get props => [id, email, firstName, lastName, role, department, position, isActive];
}