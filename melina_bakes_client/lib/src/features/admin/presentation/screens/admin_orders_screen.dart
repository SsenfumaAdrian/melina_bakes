/// Admin orders management screen with filters, pagination, and
/// inline status updates.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/admin_order_list_item_entity.dart';
import '../providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _StatusFilterBar(
            selected: state.filter.statusFilter,
            onChanged: (s) => ref.read(adminOrdersProvider.notifier).setStatusFilter(s),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd, vertical: UIConstants.spacingSm),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by order #, customer, email...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) async {
                final query = v.trim().isEmpty ? null : v.trim();
                await ref.read(adminOrdersProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          Expanded(child: _Body(state: state)),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final AdminOrdersState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingIndicator(message: 'Loading orders...');
    }
    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(
        message: state.error!.message,
        onRetry: () => ref.read(adminOrdersProvider.notifier).refresh(),
      );
    }
    if (!state.isLoading && state.items.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders found',
        subtitle: 'Try adjusting your filters or search query.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(adminOrdersProvider.notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200 &&
              state.hasNextPage && !state.isLoadingNext) {
            ref.read(adminOrdersProvider.notifier).loadNextPage();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: UIConstants.spacingSm),
          itemBuilder: (context, index) {
            if (state.hasNextPage && index == state.items.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(UIConstants.spacingLg), child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return _OrderCard(item: state.items[index], index: index);
          },
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final void Function(String? status) onChanged;
  const _StatusFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final statuses = <String?>[null, ...OrderStatus.values.map((s) => s.name)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd),
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final status = statuses[index];
            return FilterChip(
              label: Text(status == null ? 'All' : status),
              selected: selected == status,
              onSelected: (_) => onChanged(status),
              visualDensity: VisualDensity.comfortable,
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final AdminOrderListItemEntity item;
  final int index;
  const _OrderCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd, vertical: 0),
        title: Text(item.orderNumber, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('${item.customerName} • ${item.createdAt.split('T').first}',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$${item.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            Text(item.status, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(UIConstants.spacingMd, 0, UIConstants.spacingMd, UIConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${item.customerName}', style: theme.textTheme.bodyMedium),
                Text('Email: ${item.customerEmail}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                Text('Payment: ${item.paymentStatus}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                const SizedBox(height: UIConstants.spacingMd),
                Wrap(
                  spacing: UIConstants.spacingSm,
                  children: OrderStatus.values.map((status) {
                    final selected = item.status == status.name;
                    return ChoiceChip(
                      label: Text(status.displayName),
                      selected: selected,
                      onSelected: selected ? null : (_) async {
                        final ok = await ref.read(adminOrdersProvider.notifier).updateOrderStatus(
                          orderId: item.id, newStatus: status.name,
                        );
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update order status')),
                          );
                        } else if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order marked as ${status.displayName}')),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 40).ms).fadeIn().slideX(begin: -0.05, end: 0);
  }
}