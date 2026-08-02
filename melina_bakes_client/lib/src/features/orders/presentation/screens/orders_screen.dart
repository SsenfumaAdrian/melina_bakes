/// Order history screen with paginated list, status filtering, and
/// empty / loading / error states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../domain/entities/order_list_item_entity.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _StatusFilterBar(
            selected: state.statusFilter,
            onChanged: (s) => ref.read(ordersProvider.notifier).setStatusFilter(s),
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.items.isEmpty) {
            return const LoadingIndicator(message: 'Loading your orders...');
          }

          if (state.error != null && state.items.isEmpty) {
            return ErrorStateWidget(
              message: state.error!.message,
              onRetry: () => ref.read(ordersProvider.notifier).refresh(),
            );
          }

          if (!state.isLoading && state.items.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: state.statusFilter != null
                  ? 'No ${state.statusFilter!.displayName} orders found.'
                  : 'Your completed and upcoming orders will appear here.',
              actionLabel: 'Start Shopping',
              onAction: state.statusFilter != null ? null : () => context.go(RouteNames.products),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200 &&
                    state.hasNextPage &&
                    !state.isLoadingNext) {
                  ref.read(ordersProvider.notifier).loadNextPage();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: UIConstants.spacingSm),
                itemBuilder: (context, index) {
                  if (state.hasNextPage && index == state.items.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(UIConstants.spacingLg),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return _OrderCard(item: state.items[index], index: index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final OrderStatus? controller;
  final void Function(OrderStatus? status) onFilter;

  const _StatusFilterBar({required this.controller, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final statuses = <OrderStatus?>[null, ...OrderStatus.values];

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
            final isSelected = controller == status;
            final label = status == null ? 'All' : status.displayName;

            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onFilter(status),
              visualDensity: VisualDensity.comfortable,
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderListItemEntity item;
  final int index;

  const _OrderCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(UIConstants.borderRadius),
        onTap: () => context.go('${RouteNames.orders}/${item.orderNumber}'),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.orderNumber,
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        OrderStatusBadge(status: item.status, compact: true),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Row(
                      children: [
                        Icon(Icons.receipt_rounded, size: 14, color: AppColors.onLightLow),
                        const SizedBox(width: 4),
                        Text(
                          '${item.itemCount} items',
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onLightMedium,
                              ),
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        Text(
                          item.createdAt.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onLightLow,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              Icon(Icons.chevron_right_rounded, color: AppColors.onLightLow),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: -0.05, end: 0);
  }
}