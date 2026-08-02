/// Admin products management screen with search, status filter,
/// and inline featured toggle / delete actions.
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
import '../../domain/entities/admin_product_entity.dart';
import '../providers/admin_provider.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _StatusFilterBar(
            selected: state.statusFilter,
            onChanged: (s) => ref.read(adminProductsProvider.notifier).setStatusFilter(s),
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
                hintText: 'Search by name or SKU...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) async {
                final query = v.trim().isEmpty ? null : v.trim();
                await ref.read(adminProductsProvider.notifier).setSearchQuery(query);
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
  final AdminProductsState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.items.isEmpty) return const LoadingIndicator(message: 'Loading products...');
    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(message: state.error!.message, onRetry: () => ref.read(adminProductsProvider.notifier).refresh());
    }
    if (!state.isLoading && state.items.isEmpty) {
      return const EmptyState(icon: Icons.inventory_2_outlined, title: 'No products found', subtitle: 'Try adjusting your filters.');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(adminProductsProvider.notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && state.hasNextPage && !state.isLoadingNext) {
            ref.read(adminProductsProvider.notifier).loadNextPage();
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
            return _ProductCard(item: state.items[i], index: i);
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
    final statuses = <String?>[null, ...ProductStatus.values.map((s) => s.name)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd),
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final s = statuses[i];
            return FilterChip(label: Text(s ?? 'All'), selected: selected == s, onSelected: (_) => onChanged(s), visualDensity: VisualDensity.comfortable);
          },
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final AdminProductEntity item;
  final int index;
  const _ProductCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(item.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: UIConstants.spacingSm),
                    Chip(label: Text(item.status.displayName), visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
                  ]),
                  const SizedBox(height: UIConstants.spacingXs),
                  Text('SKU: ${item.sku}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                  if (item.categoryName != null)
                    Text('Category: ${item.categoryName}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                  Text('Stock: ${item.quantityInStock}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${item.basePrice.toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                if (item.salePrice != null)
                  Text('Sale \$${item.salePrice!.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(item.isFeatured ? Icons.star : Icons.star_border, color: item.isFeatured ? AppColors.warning : AppColors.onLightLow),
                      tooltip: 'Toggle featured',
                      onPressed: () async {
                        final ok = await ref.read(adminProductsProvider.notifier).toggleFeatured(productId: item.id, isFeatured: !item.isFeatured);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Featured updated' : 'Update failed')));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                          title: const Text('Delete product?'),
                          content: Text('Are you sure you want to delete "${item.name}"?'),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))],
                        ));
                        if (confirmed == true) {
                          final ok = await ref.read(adminProductsProvider.notifier).deleteProduct(item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Product deleted' : 'Delete failed')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn();
  }
}