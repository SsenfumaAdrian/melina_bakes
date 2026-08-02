/// Live order tracking screen showing current status and a visual
/// lifecycle timeline with progress indicator.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/entities/order_status_event_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_chip.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTracking = ref.watch(orderTrackingProvider(orderNumber));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Track #$orderNumber')),
      body: asyncTracking.when(
        loading: () => const LoadingIndicator(message: 'Loading tracking...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(orderTrackingProvider(orderNumber)),
        ),
        data: (tracking) => _TrackingContent(tracking: tracking, theme: theme),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  final OrderTrackingEntity tracking;
  final ThemeData theme;

  const _TrackingContent({required this.tracking, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      children: [
        // Progress indicator card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLg),
            child: Column(
              children: [
                OrderStatusBadge(status: tracking.currentStatus),
                const SizedBox(height: UIConstants.spacingMd),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: tracking.progress,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      OrderStatusChip.colorFor(tracking.currentStatus),
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSm),
                Text(
                  '${(tracking.progress * 100).round()}% complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onLightMedium,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: UIConstants.spacingMd),

        // Estimated times card
        if (tracking.estimatedDelivery != null || tracking.estimatedCompletion != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated Times', style: theme.textTheme.titleMedium),
                  const SizedBox(height: UIConstants.spacingSm),
                  if (tracking.estimatedCompletion != null)
                    _InfoRow(
                      icon: Icons.schedule,
                      label: 'Preparation ready by',
                      value: _formatDate(tracking.estimatedCompletion!),
                    ),
                  if (tracking.estimatedDelivery != null) ...[
                    const SizedBox(height: UIConstants.spacingSm),
                    _InfoRow(
                      icon: Icons.local_shipping,
                      label: 'Estimated delivery',
                      value: _formatDate(tracking.estimatedDelivery!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (tracking.estimatedDelivery != null || tracking.estimatedCompletion != null)
          const SizedBox(height: UIConstants.spacingMd),

        // Timeline card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Timeline', style: theme.textTheme.titleMedium),
                const SizedBox(height: UIConstants.spacingSm),
                ...tracking.timeline.asMap().entries.map(
                      (entry) => _TimelineEntry(
                        event: entry.value,
                        index: entry.key,
                        isLast: entry.key == tracking.timeline.length - 1,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year}, $hour:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onLightMedium),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final OrderStatusEventEntity event;
  final int index;
  final bool isLast;

  const _TimelineEntry({required this.event, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = OrderStatusChip.colorFor(event.status);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Indicator column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (index != 0)
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
              padding: EdgeInsets.symmetric(
                top: index == 0 ? 0 : UIConstants.spacingSm,
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
    ).animate(delay: (index * 60).ms).fadeIn();
  }
}
