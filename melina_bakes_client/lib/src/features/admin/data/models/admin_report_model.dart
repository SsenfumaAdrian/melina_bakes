library;

import '../../domain/entities/admin_report_entity.dart';

class AdminReportModel {
  AdminReportModel._();
  static AdminReportEntity fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final period = json['period'] as Map<String, dynamic>? ?? {};
    return AdminReportEntity(
      reportType: json['reportType'] as String? ?? '',
      dateFrom: period['from'] as String?,
      dateTo: period['to'] as String?,
      totalRevenue: (summary['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalOrders: summary['totalOrders'] as int? ?? 0,
      totalCustomers: summary['totalCustomers'] as int? ?? 0,
    );
  }
}