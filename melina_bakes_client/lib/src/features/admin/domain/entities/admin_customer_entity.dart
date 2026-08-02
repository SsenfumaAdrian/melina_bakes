/// Domain entity representing a customer as seen by the admin panel.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminCustomerEntity extends Equatable {
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

  const AdminCustomerEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.role = UserRole.customer,
    this.isActive = true,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.createdAt,
  });

  String get fullName => [firstName, lastName].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ') ?? email;
  String get initials => fullName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();

  @override
  List<Object?> get props => [id, email, firstName, lastName, phoneNumber, role, isActive, totalOrders, totalSpent, createdAt];
}