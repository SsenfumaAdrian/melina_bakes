/// Domain entity representing the admin dashboard overview statistics.
library;

import 'package:equatable/equatable.dart';

class AdminDashboardEntity extends Equatable {
  /// KPI overview.
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final double averageOrderValue;
  final double conversionRate;

  /// Today's stats.
  final double todayRevenue;
  final int todayOrders;
  final int todayNewCustomers;

  /// This week's stats.
  final double weekRevenue;
  final int weekOrders;
  final int weekNewCustomers;

  /// This month's stats.
  final double monthRevenue;
  final int monthOrders;
  final int monthNewCustomers;

  /// Order status breakdown (count per status name).
  final Map<String, int> orderStatusBreakdown;

  final List<AdminTopProductEntity> topProducts;
  final List<AdminRecentOrderEntity> recentOrders;
  final List<AdminLowStockAlertEntity> lowStockAlerts;

  const AdminDashboardEntity({
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.totalCustomers = 0,
    this.averageOrderValue = 0,
    this.conversionRate = 0,
    this.todayRevenue = 0,
    this.todayOrders = 0,
    this.todayNewCustomers = 0,
    this.weekRevenue = 0,
    this.weekOrders = 0,
    this.weekNewCustomers = 0,
    this.monthRevenue = 0,
    this.monthOrders = 0,
    this.monthNewCustomers = 0,
    this.orderStatusBreakdown = const {},
    this.topProducts = const [],
    this.recentOrders = const [],
    this.lowStockAlerts = const [],
  });

  @override
  List<Object?> get props => [
        totalRevenue, totalOrders, totalCustomers, averageOrderValue,
        conversionRate, todayRevenue, todayOrders, todayNewCustomers,
        weekRevenue, weekOrders, weekNewCustomers, monthRevenue,
        monthOrders, monthNewCustomers, orderStatusBreakdown,
        topProducts, recentOrders, lowStockAlerts,
      ];
}

class AdminTopProductEntity extends Equatable {
  final String name;
  final int sales;
  final double revenue;

  const AdminTopProductEntity({required this.name, required this.sales, required this.revenue});

  @override
  List<Object?> get props => [name, sales, revenue];
}

class AdminRecentOrderEntity extends Equatable {
  final int id;
  final String orderNumber;
  final String customerName;
  final double total;
  final String status;
  final String createdAt;

  const AdminRecentOrderEntity({
    required this.id, required this.orderNumber, required this.customerName,
    required this.total, required this.status, required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderNumber, customerName, total, status, createdAt];
}

class AdminLowStockAlertEntity extends Equatable {
  final String name;
  final String sku;
  final double quantity;
  final double threshold;

  const AdminLowStockAlertEntity({
    required this.name, required this.sku, required this.quantity, required this.threshold,
  });

  @override
  List<Object?> get props => [name, sku, quantity, threshold];
}