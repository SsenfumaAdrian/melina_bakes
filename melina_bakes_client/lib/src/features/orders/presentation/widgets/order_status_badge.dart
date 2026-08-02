
/// Reusable badge displaying an [OrderStatus] with appropriate colors.
///
/// Used across the order list, order detail, and tracking screens to
/// keep status presentation visually consistent throughout the app.
library;

import 'package:flutter/material.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/theme/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusBadge({super.key, required this.status, this.compact = false});

  /// Returns the seed color for the status from the bakery palette.
  Color get _color => switch (status) {
        OrderStatus.pending => AppColors.warning,
        OrderStatus.confirmed => AppColors.info,
        OrderStatus.preparing => const Color(0xFF5C6BC0),
        OrderStatus.baking => AppColors.primary,
        OrderStatus.ready => AppColors.success,
        OrderStatus.outForDelivery => const Color(0xFF00897B),
        OrderStatus.completed => const Color(0xFF2E7D32),
        OrderStatus.cancelled => AppColors.error,
      };

  /// Returns the contrasting text/icon color over the seed color.
  Color get _onColor => switch (status) {
        OrderStatus.pending => Colors.brown,
        OrderStatus.confirmed => Colors.white,
        OrderStatus.preparing => Colors.white,
        OrderStatus.baking => Colors.white,
        OrderStatus.ready => Colors.white,
        OrderStatus.outForDelivery => Colors.white,
        OrderStatus.completed => Colors.white,
        OrderStatus.cancelled => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForStatus(status),
            size: compact ? 12 : 14,
            color: color,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus(OrderStatus s) => switch (s) {
        OrderStatus.pending => Icons.hourglass_top_rounded,
        OrderStatus.confirmed => Icons.verified_rounded,
        OrderStatus.preparing => Icons.soup_kitchen_outlined,
        OrderStatus.baking => Icons.local_fire_department_outlined,
        OrderStatus.ready => Icons.task_alt_rounded,
        OrderStatus.outForDelivery => Icons.delivery_dining_outlined,
        OrderStatus.completed => Icons.check_circle_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
      };

  /// Exposes the seed color so callers can colorize siblings consistently.
  Color get seedColor => _color;

  /// Exposes the contrast color so siblings can colorize text/iconography.
  Color get onColor => _onColor;
}
