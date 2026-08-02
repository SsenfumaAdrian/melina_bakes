
/// Vertical timeline visualizing the lifecycle stages of an order.
///
/// Renders each [OrderStatusEventEntity] as a step with an indicator,
/// connector line, label, timestamp, and optional note. Completed
/// stages are emphasized while future stages are rendered subtly.
library;

import 'package:flutter/material.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_status_event_entity.dart';
import 'order_status_chip.dart';

class OrderTimeline extends StatelessWidget {
  final List<OrderStatusEventEntity> events;
  final bool showCurrentHighlight;

  const OrderTimeline({
    super.key,
    required this.events,
    this.showCurrentHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLg),
        child: Text(
          'No status updates yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onLightMedium,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineStep(
            event: events[i],
            isLast: i == events.length - 1,
            isFirst: i == 0,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final OrderStatusEventEntity event;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = OrderStatusChip.colorFor(event.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator + connector column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top connector (hidden for first item)
                if (!isFirst)
                  Container(width: 2, height: 12, color: AppColors.border),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: event.completed ? accent : accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent,
                      width: event.completed ? 0 : 2,
                    ),
                  ),
                  child: Icon(
                    event.completed ? Icons.check_rounded : Icons.circle,
                    size: event.completed ? 14 : 6,
                    color: event.completed ? Colors.white : accent,
                  ),
                ),
                // Bottom connector (hidden for last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: event.completed ? accent : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: UIConstants.spacingSm),
          // Label + timestamp
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : UIConstants.spacingSm,
                bottom: isLast ? 0 : UIConstants.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.displayLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: event.completed ? FontWeight.bold : FontWeight.w500,
                      color: event.completed ? AppColors.onLightHigh : AppColors.onLightMedium,
                    ),
                  ),
                  if (event.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(event.timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onLightLow,
                      ),
                    ),
                  ],
                  if (event.note != null && event.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onLightMedium,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime t) {
    final local = t.toLocal();
    final date = '${local.day}/${local.month}/${local.year}';
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$date, $hour:$minute $period';
  }
}
