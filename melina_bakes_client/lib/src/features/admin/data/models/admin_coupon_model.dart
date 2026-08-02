library;

import '../../domain/entities/admin_coupon_entity.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

class AdminCouponModel {
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

  AdminCouponModel({
    required this.id, required this.code, this.description, required this.type,
    required this.value, this.minOrderAmount, this.startsAt, this.endsAt,
    this.usageLimit, this.usedCount = 0, this.isActive = true,
  });

  factory AdminCouponModel.fromJson(Map<String, dynamic> json) => AdminCouponModel(
        id: json['id'] as int? ?? 0,
        code: json['code'] as String? ?? '',
        description: json['description'] as String?,
        type: _parseType(json['type'] as String?),
        value: (json['value'] as num?)?.toDouble() ?? 0,
        minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
        startsAt: DateTime.tryParse(json['startsAt'] as String? ?? '')?.toUtc(),
        endsAt: DateTime.tryParse(json['endsAt'] as String? ?? '')?.toUtc(),
        usageLimit: json['usageLimit'] as int?,
        usedCount: json['usedCount'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );

  AdminCouponEntity toEntity() => AdminCouponEntity(
        id: id, code: code, description: description, type: type,
        value: value, minOrderAmount: minOrderAmount, startsAt: startsAt,
        endsAt: endsAt, usageLimit: usageLimit, usedCount: usedCount, isActive: isActive,
      );
}

CouponType _parseType(String? v) {
  if (v == null) return CouponType.percentage;
  try { return CouponType.values.byName(v); } on ArgumentError { return CouponType.percentage; }
}