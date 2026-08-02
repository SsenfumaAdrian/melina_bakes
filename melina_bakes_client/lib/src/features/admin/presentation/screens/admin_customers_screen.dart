/// Admin customers management screen with search and pagination.
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
import '../../domain/entities/admin_customer_entity.dart';
import '../providers/admin_provider.dart';

class AdminCustomersScreen extends ConsumerWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCustomersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd, vertical: UIConstants.spacingSm),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name or email...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) async {
                final query = v.trim().isEmpty ? null : v.trim();
                await ref.read(adminCustomersProvider.notifier).setSearchQuery(query);
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
  final AdminCustomersState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.items.isEmpty) return const LoadingIndicator(message: 'Loading customers...');
    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(message: state.error!.message, onRetry: () => ref.read(adminCustomersProvider.notifier).refresh());
    }
    if (!state.isLoading && state.items.isEmpty) return const EmptyState(icon: Icons.people_outline, title: 'No customers found');
    return RefreshIndicator(
      onRefresh: () => ref.read(adminCustomersProvider.notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && state.hasNextPage && !state.isLoadingNext) {
            ref.read(adminCustomersProvider.notifier).loadNextPage();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: UIConstants.spacingSm),
          itemBuilder: (context, i) {
            if (state.hasNextPage && i == state.items.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(UIConstants.spacingLg), child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return _CustomerCard(item: state.items[i], index: i);
          },
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final AdminCustomerEntity item;
  final int index;
  const _CustomerCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = item.initials;
    final displayName = [item.firstName, item.lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(UIConstants.spacingMd),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(initials.isEmpty ? '?' : initials, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Text(displayName.isEmpty ? item.email : displayName,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (!item.isActive) ...[
              const SizedBox(width: 6),
              const Chip(label: Text('Inactive'), visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.email, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
            if (item.phoneNumber != null)
              Text(item.phoneNumber!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${item.totalOrders} orders', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                const SizedBox(width: UIConstants.spacingSm),
                Text('\$${item.totalSpent.toStringAsFixed(2)} spent', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn().slideX(begin: -0.05, end: 0);
  }
}