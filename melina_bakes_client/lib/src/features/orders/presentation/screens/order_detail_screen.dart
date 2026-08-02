/// Full order detail screen showing items, pricing, delivery address,
/// status timeline, and action buttons (cancel, track).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderNumber;

  const OrderDetailScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrder = ref.watch(orderDetailProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderNumber'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.track_changes_rounded),
            label: const Text('Track'),
            onPressed: () => context.push(
              '${RouteNames.orders}/$orderNumber/track',
            ),
          ),
        ],
      ),
      body: asyncOrder.when(
        loading: () => const LoadingIndicator(message: 'Loading order details...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderNumber)),
        ),
        data: (order) => _OrderDetailContent(order: order),
      ),
    );
  }
}

class _OrderDetailContent extends ConsumerWidget {
  final OrderEntity order;
  const _OrderDetailContent({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      children: [
        _buildStatusCard(context, ref, theme),
        const SizedBox(height: UIConstants.spacingMd),
        _buildItemsCard(context, theme),
        const SizedBox(height: UIConstants.spacingMd),
        _buildPricingCard(context, theme),
        const SizedBox(height: UIConstants.spacingMd),
        if (order.deliveryAddress != null) _buildAddressCard(context, theme),
        if (order.customerNotes != null && order.customerNotes!.trim().isNotEmpty)
          _buildNotesCard(context, theme),
        if (order.deliveryAddress != null || (order.customerNotes != null && order.customerNotes!.trim().isNotEmpty))
          const SizedBox(height: UIConstants.spacingMd),
        _buildTimelineCard(context, theme),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingLg),
        child: Column(
          children: [
            Row(
              children: [
                OrderStatusBadge(status: order.status),
                const Spacer(),
                if (order.canCancel)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                    label: const Text('Cancel Order'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => _confirmCancel(context, ref),
                  ),
              ],
            ),
            if (order.estimatedDeliveryDate != null) ...[
              const SizedBox(height: UIConstants.spacingMd),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated delivery: ${_formatDate(order.estimatedDeliveryDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onLightMedium,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items', style: theme.textTheme.titleMedium),
            const SizedBox(height: UIConstants.spacingSm),
            ...order.items.asMap().entries.map((entry) => _ItemRow(
                  item: entry.value,
                  index: entry.key,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: UIConstants.spacingSm),
            _SummaryRow(
              label: 'Subtotal',
              value: '\$${order.subtotal.toStringAsFixed(2)}',
              theme: theme,
            ),
            if (order.discountAmount > 0)
              _SummaryRow(
                label: order.couponCode != null
                    ? 'Discount (${order.couponCode})'
                    : 'Discount',
                value: '-\$${order.discountAmount.toStringAsFixed(2)}',
                theme: theme,
                isDiscount: true,
              ),
            _SummaryRow(
              label: 'Tax',
              value: '\$${order.taxAmount.toStringAsFixed(2)}',
              theme: theme,
            ),
            _SummaryRow(
              label: 'Delivery',
              value: '\$${order.deliveryCharge.toStringAsFixed(2)}',
              theme: theme,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Total',
              value: '\$${order.total.toStringAsFixed(2)}',
              theme: theme,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, ThemeData theme) {
    final addr = order.deliveryAddress!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Delivery Address', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            Text(
              addr.displayLine,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onLightMedium,
                  ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
    );
  }

  Widget _buildNotesCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 8),
                Text('Your Notes', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            Text(
              order.customerNotes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onLightMedium,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Timeline', style: theme.textTheme.titleMedium),
            const SizedBox(height: UIConstants.spacingSm),
            OrderTimeline(events: order.statusHistory),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(orderMutationProvider.notifier).cancelOrder(orderId: order.id);
            },
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemEntity item;
  final int index;

  const _ItemRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingSm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.primaryContainer,
              child: item.productImageUrl != null
                  ? Image.network(item.productImageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.bakery_dining, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onLightMedium,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onLightMedium,
                    ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    )
                : theme.textTheme.bodyMedium?.copyWith(
                      color: isDiscount ? AppColors.success : AppColors.onLightHigh,
                      fontWeight: isDiscount ? FontWeight.bold : null,
                    ),
          ),
        ],
      ),
    );
  }
}