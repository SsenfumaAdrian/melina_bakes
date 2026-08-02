/// Admin inventory management screen showing stock levels and status.
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
import '../../domain/entities/inventory_ingredient_entity.dart';
import '../providers/admin_provider.dart';

class AdminInventoryScreen extends ConsumerWidget {
  const AdminInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminInventoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: async.when(
        loading: () => const LoadingIndicator(message: 'Loading inventory...'),
        error: (e, _) => ErrorStateWidget(message: e.toString().replaceFirst('Exception: ', ''), onRetry: () => ref.refresh(adminInventoryProvider)),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(icon: Icons.inventory_2_outlined, title: 'No ingredients tracked', subtitle: 'Add ingredients to start tracking stock.');
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(adminInventoryProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(UIConstants.spacingMd),
              itemCount: items.length,
              itemBuilder: (context, i) => _IngredientCard(item: items[i], index: i),
            ),
          );
        },
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final InventoryIngredientEntity item;
  final int index;
  const _IngredientCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    switch (item.status) {
      case InventoryStatus.outOfStock:
        statusColor = AppColors.error;
        break;
      case InventoryStatus.critical:
      case InventoryStatus.lowStock:
        statusColor = AppColors.warning;
        break;
      case InventoryStatus.inStock:
        statusColor = AppColors.success;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text('SKU: ${item.sku}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                  if (item.supplierName != null)
                    Text('Supplier: ${item.supplierName}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                  Row(
                    children: [
                      Text('${item.quantityInStock.toStringAsFixed(1)} ${item.unitOfMeasure}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      const SizedBox(width: UIConstants.spacingSm),
                      Text('reorder @ ${item.reorderLevel.toStringAsFixed(1)}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                    ],
                  ),
                ],
              ),
            ),
            Chip(label: Text(item.status.displayName), backgroundColor: statusColor.withOpacity(0.15)),
          ],
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}