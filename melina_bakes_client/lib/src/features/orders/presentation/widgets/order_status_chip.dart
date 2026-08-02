
/// Lightweight status chip and shared color accessor for [OrderStatus].
///
/// The [colorFor] static method is consumed by other order widgets
/// (timeline, tracking) to keep visual colorization consistent across
/// the feature.
library;

import 'package:flutter/material.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/theme/app_colors.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusChip({super.key, required this.status, this.compact = false});

  /// Canonical seed color for a given status.
  static Color colorFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => Colors.orange.shade600,
        OrderStatus.confirmed => Colors.blue.shade600,
        OrderStatus.preparing => const Color(0xFF5C6BC0),
        OrderStatus.baking => const Color(0xFFEF6C00),
        OrderStatus.ready => const Color(0xFF2E7D32),
        OrderStatus.outForDelivery => const Color(0xFF00897B),
        OrderStatus.completed => const Color(0xFF2E7D32),
        OrderStatus.cancelled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
