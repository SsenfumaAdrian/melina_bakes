library;

import '../../domain/entities/admin_dashboard_entity.dart';

class AdminTopProductModel {
  final String name;
  final int sales;
  final double revenue;
  AdminTopProductModel({required this.name, required this.sales, required this.revenue});
  factory AdminTopProductModel.fromJson(Map<String, dynamic> json) => AdminTopProductModel(
        name: json['name'] as String? ?? '',
        sales: json['sales'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );
  AdminTopProductEntity toEntity() => AdminTopProductEntity(name: name, sales: sales, revenue: revenue);
}

class AdminRecentOrderModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final double total;
  final String status;
  final String createdAt;
  AdminRecentOrderModel({
    required this.id, required this.orderNumber, required this.customerName,
    required this.total, required this.status, required this.createdAt,
  });
  factory AdminRecentOrderModel.fromJson(Map<String, dynamic> json) => AdminRecentOrderModel(
        id: json['id'] as int? ?? 0,
        orderNumber: json['orderNumber'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
  AdminRecentOrderEntity toEntity() => AdminRecentOrderEntity(id: id, orderNumber: orderNumber, customerName: customerName, total: total, status: status, createdAt: createdAt);
}

class AdminLowStockAlertModel {
  final String name;
  final String sku;
  final double quantity;
  final double threshold;
  AdminLowStockAlertModel({required this.name, required this.sku, required this.quantity, required this.threshold});
  factory AdminLowStockAlertModel.fromJson(Map<String, dynamic> json) => AdminLowStockAlertModel(
        name: json['name'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
      );
  AdminLowStockAlertEntity toEntity() => AdminLowStockAlertEntity(name: name, sku: sku, quantity: quantity, threshold: threshold);
}

class AdminDashboardModel {
  // ... similar construction pattern
  const AdminDashboardModel._();
  static AdminDashboardEntity fromJson(Map<String, dynamic> json) {
    final o = json['overview'] as Map<String, dynamic>? ?? {};
    final t = json['today'] as Map<String, dynamic>? ?? {};
    final w = json['thisWeek'] as Map<String, dynamic>? ?? {};
    final m = json['thisMonth'] as Map<String, dynamic>? ?? {};
    final breakdown = Map<String, int>.from((json['orderStatusBreakdown'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {});
    final tops = (json['topProducts'] as List<dynamic>? ?? []).map((e) => AdminTopProductModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    final recents = (json['recentOrders'] as List<dynamic>? ?? []).map((e) => AdminRecentOrderModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    final alerts = (json['lowStockAlerts'] as List<dynamic>? ?? []).map((e) => AdminLowStockAlertModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    return AdminDashboardEntity(
      totalRevenue: (o['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalOrders: o['totalOrders'] as int? ?? 0,
      totalCustomers: o['totalCustomers'] as int? ?? 0,
      averageOrderValue: (o['averageOrderValue'] as num?)?.toDouble() ?? 0,
      conversionRate: (o['conversionRate'] as num?)?.toDouble() ?? 0,
      todayRevenue: (t['revenue'] as num?)?.toDouble() ?? 0,
      todayOrders: t['orders'] as int? ?? 0,
      todayNewCustomers: t['newCustomers'] as int? ?? 0,
      weekRevenue: (w['revenue'] as num?)?.toDouble() ?? 0,
      weekOrders: w['orders'] as int? ?? 0,
      weekNewCustomers: w['newCustomers'] as int? ?? 0,
      monthRevenue: (m['revenue'] as num?)?.toDouble() ?? 0,
      monthOrders: m['orders'] as int? ?? 0,
      monthNewCustomers: m['newCustomers'] as int? ?? 0,
      orderStatusBreakdown: breakdown,
      topProducts: tops,
      recentOrders: recents,
      lowStockAlerts: alerts,
    );
  }
}