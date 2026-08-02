/// Admin reports screen driven by report type and date range.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_boundary.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../providers/admin_provider.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String _reportType = 'sales';
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final filter = AdminReportsFilter(
      reportType: _reportType,
      dateFrom: _range?.start.toIso8601String().split('T').first,
      dateTo: _range?.end.toIso8601String().split('T').first,
    );
    final async = ref.watch(adminReportsProvider(filter));
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _reportType,
                    decoration: const InputDecoration(labelText: 'Report type', border: OutlineInputBorder(), isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'sales', child: Text('Sales')),
                      DropdownMenuItem(value: 'orders', child: Text('Orders')),
                      DropdownMenuItem(value: 'customers', child: Text('Customers')),
                      DropdownMenuItem(value: 'inventory', child: Text('Inventory')),
                    ],
                    onChanged: (v) => setState(() => _reportType = v ?? 'sales'),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingSm),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_range == null ? 'Date range' : '${_range!.start.toString().split(' ')[0]} – ${_range!.end.toString().split(' ')[0]}'),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 3),
                      lastDate: now,
                      initialDateRange: _range ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
                    );
                    if (picked != null) setState(() => _range = picked);
                  },
                ),
              ],
            ),
          ),
          if (_range != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: UIConstants.spacingMd),
                child: TextButton(onPressed: () => setState(() => _range = null), child: const Text('Clear date range')),
              ),
            ),
          Expanded(
            child: async.when(
              loading: () => const LoadingIndicator(message: 'Building report...'),
              error: (e, _) => ErrorStateWidget(message: e.toString().replaceFirst('Exception: ', '')),
              data: (report) => _ReportView(report: report),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  final AdminReportEntity report;
  const _ReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(UIConstants.spacingMd),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titleFor(report), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (report.dateFrom != null || report.dateTo != null) ...[
                  const SizedBox(height: UIConstants.spacingXs),
                  Text('${report.dateFrom ?? '…'} – ${report.dateTo ?? '…'}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
                ],
                const SizedBox(height: UIConstants.spacingLg),
                _SummaryRow(label: 'Total revenue', value: '\$${report.totalRevenue.toStringAsFixed(2)}'),
                _SummaryRow(label: 'Total orders', value: report.totalOrders.toString()),
                _SummaryRow(label: 'Total customers', value: report.totalCustomers.toString()),
              ],
            ),
          ),
        ).animate().fadeIn(),
      ],
    );
  }

  String _titleFor(AdminReportEntity r) {
    switch (r.reportType) {
      case 'sales':
        return 'Sales Report';
      case 'orders':
        return 'Orders Report';
      case 'customers':
        return 'Customers Report';
      case 'inventory':
        return 'Inventory Report';
      default:
        return 'Report';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}