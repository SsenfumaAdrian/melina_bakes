/// Admin coupons management screen.
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
import '../../domain/entities/admin_coupon_entity.dart';
import '../providers/admin_provider.dart';

class AdminCouponsScreen extends ConsumerWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCouponsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Coupons')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Coupon'),
        onPressed: () => _showCreateDialog(context, ref),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.items.isEmpty) return const LoadingIndicator(message: 'Loading coupons...');
          if (state.error != null && state.items.isEmpty) {
            return ErrorStateWidget(message: state.error!.message, onRetry: () => ref.read(adminCouponsProvider.notifier).refresh());
          }
          if (!state.isLoading && state.items.isEmpty) {
            return const EmptyState(icon: Icons.confirmation_number_outlined, title: 'No coupons yet', subtitle: 'Create a coupon to attract more sales.');
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminCouponsProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && state.hasNextPage && !state.isLoadingNext) {
                  ref.read(adminCouponsProvider.notifier).loadNextPage();
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
                  return _CouponCard(item: state.items[i], index: i);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => const _CreateCouponDialog());
  }
}

class _CouponCard extends ConsumerWidget {
  final AdminCouponEntity item;
  final int index;
  const _CouponCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final discountLabel = item.type == CouponType.percentage
        ? '${item.value.toStringAsFixed(0)}% off'
        : '\$${item.value.toStringAsFixed(2)} off';
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
                  Row(
                    children: [
                      Text(item.code, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(width: UIConstants.spacingSm),
                      Chip(label: Text(discountLabel), visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
                      if (!item.isActive) ...[
                        const SizedBox(width: 4),
                        const Chip(label: Text('Inactive'), visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
                      ],
                    ],
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(item.description!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                  ],
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: UIConstants.spacingSm,
                    children: [
                      if (item.minOrderAmount != null) Text('min \$${item.minOrderAmount!.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                      if (item.usageLimit != null) Text('limit ${item.usageLimit}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                      Text('used ${item.usedCount}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                      if (item.endsAt != null) Text('ends ${item.endsAt!.toIso8601String().split('T').first}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('Delete coupon?'),
                  content: Text('Delete coupon "${item.code}"?'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))],
                ));
                if (confirmed == true) {
                  final ok = await ref.read(adminCouponsProvider.notifier).deleteCoupon(item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Coupon deleted' : 'Delete failed')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn();
  }
}

class _CreateCouponDialog extends ConsumerStatefulWidget {
  const _CreateCouponDialog();

  @override
  ConsumerState<_CreateCouponDialog> createState() => _CreateCouponDialogState();
}

class _CreateCouponDialogState extends ConsumerState<_CreateCouponDialog> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _value = TextEditingController();
  final _minOrder = TextEditingController();
  final _usageLimit = TextEditingController();
  CouponType _type = CouponType.percentage;

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    _value.dispose();
    _minOrder.dispose();
    _usageLimit.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    final coupon = await ref.read(adminCouponsProvider.notifier).createCoupon(
      code: _code.text.trim().toUpperCase(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      type: _type.name,
      value: double.parse(_value.text.trim()),
      minOrderAmount: _minOrder.text.trim().isEmpty ? null : double.tryParse(_minOrder.text.trim()),
      usageLimit: _usageLimit.text.trim().isEmpty ? null : int.tryParse(_usageLimit.text.trim()),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(coupon != null ? 'Coupon created' : 'Failed to create coupon')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Coupon'),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _code, decoration: const InputDecoration(labelText: 'Code *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: UIConstants.spacingSm),
                TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: UIConstants.spacingSm),
                DropdownButtonFormField<CouponType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: CouponType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                  onChanged: (v) => setState(() => _type = v ?? CouponType.percentage),
                ),
                const SizedBox(height: UIConstants.spacingSm),
                TextFormField(
                  controller: _value,
                  decoration: const InputDecoration(labelText: 'Value *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = v == null ? null : double.tryParse(v);
                    return n == null ? 'Enter a number' : null;
                  },
                ),
                const SizedBox(height: UIConstants.spacingSm),
                TextFormField(controller: _minOrder, decoration: const InputDecoration(labelText: 'Min order amount'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: UIConstants.spacingSm),
                TextFormField(controller: _usageLimit, decoration: const InputDecoration(labelText: 'Usage limit'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')), FilledButton(onPressed: _submit, child: const Text('Create'))],
    );
  }
}