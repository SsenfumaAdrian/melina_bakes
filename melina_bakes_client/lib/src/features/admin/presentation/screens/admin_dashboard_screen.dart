/// Admin dashboard screen with KPIs, trends, and recent activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminDashboardProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading dashboard...'),
        error: (error, _) => ErrorStateWidget(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.refresh(adminDashboardProvider),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async => ref.refresh(adminDashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            children: [
              _KpiSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
              _PeriodComparisonSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
              _OrderStatusSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
              _TopProductsSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
              _RecentOrdersSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
              _LowStockSection(dashboard: dashboard),
              const SizedBox(height: UIConstants.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _KpiSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: UIConstants.spacingSm,
      crossAxisSpacing: UIConstants.spacingSm,
      childAspectRatio: 1.6,
      children: [
        _KpiCard(
          icon: Icons.attach_money_rounded, label: 'Total Revenue',
          value: '\$${dashboard.totalRevenue.toStringAsFixed(2)}',
          color: AppColors.success,
        ),
        _KpiCard(
          icon: Icons.shopping_bag_outlined, label: 'Total Orders',
          value: dashboard.totalOrders.toString(),
          color: AppColors.primary,
        ),
        _KpiCard(
          icon: Icons.people_outline, label: 'Total Customers',
          value: dashboard.totalCustomers.toString(),
          color: AppColors.info,
        ),
        _KpiCard(
          icon: Icons.trending_up, label: 'Avg. Order Value',
          value: '\$${dashboard.averageOrderValue.toStringAsFixed(2)}',
          color: AppColors.warning,
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: UIConstants.spacingSm),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
          ],
        ),
      ),
    );
  }
}

class _PeriodComparisonSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _PeriodComparisonSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance by Period',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: UIConstants.spacingMd),
            _PeriodRow(label: 'Today', revenue: dashboard.todayRevenue, orders: dashboard.todayOrders, newCustomers: dashboard.todayNewCustomers),
            const Divider(),
            _PeriodRow(label: 'This Week', revenue: dashboard.weekRevenue, orders: dashboard.weekOrders, newCustomers: dashboard.weekNewCustomers),
            const Divider(),
            _PeriodRow(label: 'This Month', revenue: dashboard.monthRevenue, orders: dashboard.monthOrders, newCustomers: dashboard.monthNewCustomers),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}

class _PeriodRow extends StatelessWidget {
  final String label;
  final double revenue;
  final int orders;
  final int newCustomers;
  const _PeriodRow({required this.label, required this.revenue, required this.orders, required this.newCustomers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text('\$${revenue.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium, textAlign: TextAlign.end)),
          Expanded(child: Text('$orders', style: secondary, textAlign: TextAlign.end)),
          Expanded(child: Text('+$newCustomers', style: secondary, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _OrderStatusSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _OrderStatusSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    if (dashboard.orderStatusBreakdown.isEmpty) return const SizedBox.shrink();
    final total = dashboard.orderStatusBreakdown.values.fold<int>(0, (a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Status Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: UIConstants.spacingMd),
            ...dashboard.orderStatusBreakdown.entries.map((entry) {
              final pct = total > 0 ? (entry.value / total * 100).clamp(0, 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(entry.key)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.surfaceLight,
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('${entry.value}', textAlign: TextAlign.end)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ).animate(delay: 150.ms).fadeIn();
  }
}

class _TopProductsSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _TopProductsSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    if (dashboard.topProducts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Products', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: UIConstants.spacingMd),
            ...dashboard.topProducts.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text('${i + 1}', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                ),
                title: Text(p.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.sales} sold'),
                trailing: Text('\$${p.revenue.toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              );
            }),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn();
  }
}

class _RecentOrdersSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _RecentOrdersSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (dashboard.recentOrders.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.receipt_outlined, color: AppColors.onLightLow),
          title: const Text('No recent orders'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => context.go(RouteNames.adminOrders), child: const Text('View all')),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            ...dashboard.recentOrders.map((order) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.onLightLow),
              title: Text(order.orderNumber, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(order.customerName),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('\$${order.total.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(order.status, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightLow)),
                ],
              ),
            )),
          ],
        ),
      ),
    ).animate(delay: 250.ms).fadeIn();
  }
}

class _LowStockSection extends StatelessWidget {
  final AdminDashboardEntity dashboard;
  const _LowStockSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (dashboard.lowStockAlerts.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
          title: const Text('Inventory healthy'),
          subtitle: const Text('No low stock alerts'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low Stock Alerts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => context.go(RouteNames.adminInventory), child: const Text('Manage')),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            ...dashboard.lowStockAlerts.map((alert) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              title: Text(alert.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text('SKU: ${alert.sku}'),
              trailing: Text('${alert.quantity.toStringAsFixed(1)} / ${alert.threshold.toStringAsFixed(1)}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)),
            )),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn();
  }
}