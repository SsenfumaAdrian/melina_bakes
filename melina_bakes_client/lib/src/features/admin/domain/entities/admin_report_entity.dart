/// Admin-view report summary entity.
library;

import 'package:equatable/equatable.dart';

class AdminReportEntity extends Equatable {
  final String reportType;
  final String? dateFrom;
  final String? dateTo;
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;

  const AdminReportEntity({
    required this.reportType,
    this.dateFrom,
    this.dateTo,
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.totalCustomers = 0,
  });

  @override
  List<Object?> get props => [reportType, dateFrom, dateTo, totalRevenue, totalOrders, totalCustomers];
}