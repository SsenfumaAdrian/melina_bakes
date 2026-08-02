/// Admin-view coupon entity.
library;

import 'package:equatable/equatable.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminCouponEntity extends Equatable {
  final int id;
  final String code;
  final String? description;
  final CouponType type;
  final double value;
  final double? minOrderAmount;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  const AdminCouponEntity({
    required this.id,
    required this.code,
    this.description,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.startsAt,
    this.endsAt,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, code, description, type, value, minOrderAmount, startsAt, endsAt, usageLimit, usedCount, isActive];
}