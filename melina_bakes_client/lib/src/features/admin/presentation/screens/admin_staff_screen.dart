/// Admin staff management screen.
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
import '../../domain/entities/admin_staff_entity.dart';
import '../providers/admin_provider.dart';

class AdminStaffScreen extends ConsumerWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminStaffProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.items.isEmpty) return const LoadingIndicator(message: 'Loading staff...');
          if (state.error != null && state.items.isEmpty) {
            return ErrorStateWidget(message: state.error!.message, onRetry: () => ref.read(adminStaffProvider.notifier).refresh());
          }
          if (!state.isLoading && state.items.isEmpty) {
            return const EmptyState(icon: Icons.badge_outlined, title: 'No staff members', subtitle: 'Add staff members to manage roles and permissions.');
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminStaffProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && state.hasNextPage && !state.isLoadingNext) {
                  ref.read(adminStaffProvider.notifier).loadNextPage();
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
                  return _StaffCard(item: state.items[i], index: i);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final AdminStaffEntity item;
  final int index;
  const _StaffCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = item.initials;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(UIConstants.spacingMd),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondaryContainer,
          child: Text(initials, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
        ),
        title: Text('${item.firstName} ${item.lastName}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.email, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
            Row(
              children: [
                Chip(label: Text(item.role.displayName), visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
                if (item.department != null) ...[
                  const SizedBox(width: 6),
                  Chip(label: Text(item.department!), visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
                ],
                if (item.position != null) ...[
                  const SizedBox(width: 6),
                  Chip(label: Text(item.position!), visualDensity: const VisualDensity(horizontal: -4, vertical: -4)),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(item.isActive ? Icons.check_circle : Icons.pause_circle, color: item.isActive ? AppColors.success : AppColors.onLightLow),
      ),
    ).animate(delay: (index * 40).ms).fadeIn().slideX(begin: -0.05, end: 0);
  }
}