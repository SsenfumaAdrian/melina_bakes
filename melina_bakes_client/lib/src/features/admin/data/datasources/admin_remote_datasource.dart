library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../core/network/api_client.dart';
import '../../domain/entities/admin_coupon_entity.dart';
import '../../domain/entities/admin_customer_entity.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/admin_order_list_item_entity.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/entities/admin_staff_entity.dart';
import '../../domain/entities/inventory_ingredient_entity.dart';
import '../models/admin_coupon_model.dart';
import '../models/admin_customer_model.dart';
import '../models/admin_dashboard_model.dart';
import '../models/admin_order_list_item_model.dart';
import '../models/admin_product_model.dart';
import '../models/admin_report_model.dart';
import '../models/admin_staff_model.dart';
import '../models/inventory_ingredient_model.dart';

class AdminRemoteDataSource {
  final ApiClient _api;
  AdminRemoteDataSource(this._api);

  static const _base = '/admin';

  Future<Result<AdminDashboardEntity, Failure>> getDashboardStats() =>
      _api.get<Map<String, dynamic>>(
        '$_base/dashboard',
        parser: (d) => AdminDashboardModel.fromJson(d as Map<String, dynamic>),
      );

  Future<Result<PaginatedResponse<AdminOrderListItemEntity>, Failure>> listOrders({
    int page = 1, int pageSize = 20,
    String? statusFilter, String? paymentStatusFilter,
    String? dateFrom, String? dateTo, String? searchQuery,
  }) => _api.get<PaginatedResponse<AdminOrderListItemEntity>>(
    '$_base/orders',
    query: {
      'page': page, 'pageSize': pageSize,
      if (statusFilter != null) 'status': statusFilter,
      if (paymentStatusFilter != null) 'paymentStatus': paymentStatusFilter,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (searchQuery != null) 'q': searchQuery,
    },
    parser: _parsePaginated((raw) => AdminOrderListItemModel.fromJson(raw as Map<String, dynamic>).toEntity()),
  );

  Future<Result<void, Failure>> updateOrderStatus({
    required int orderId, required String newStatus, String? reason,
  }) => _api.put<void>(
    '$_base/orders/$orderId/status',
    data: {'status': newStatus, if (reason != null) 'reason': reason},
    parser: (_) {},
  );

  Future<Result<PaginatedResponse<AdminCustomerEntity>, Failure>> listCustomers({
    int page = 1, int pageSize = 20, String? searchQuery,
  }) => _api.get<PaginatedResponse<AdminCustomerEntity>>(
    '$_base/customers',
    query: {'page': page, 'pageSize': pageSize, if (searchQuery != null) 'q': searchQuery},
    parser: _parsePaginated((raw) => AdminCustomerModel.fromJson(raw as Map<String, dynamic>).toEntity()),
  );

  Future<Result<PaginatedResponse<AdminProductEntity>, Failure>> listProducts({
    int page = 1, int pageSize = 20, String? statusFilter, String? searchQuery,
  }) => _api.get<PaginatedResponse<AdminProductEntity>>(
    '$_base/products',
    query: {
      'page': page, 'pageSize': pageSize,
      if (statusFilter != null) 'status': statusFilter,
      if (searchQuery != null) 'q': searchQuery,
    },
    parser: _parsePaginated((raw) => AdminProductModel.fromJson(raw as Map<String, dynamic>).toEntity()),
  );

  Future<Result<AdminProductEntity, Failure>> createProduct(Map<String, dynamic> body) =>
      _api.post<AdminProductEntity>(
        '$_base/products',
        data: body,
        parser: (raw) => AdminProductModel.fromJson(raw as Map<String, dynamic>).toEntity(),
      );

  Future<Result<void, Failure>> updateProduct({required int productId, required Map<String, dynamic> body}) =>
      _api.put<void>('$_base/products/$productId', data: body, parser: (_) {});

  Future<Result<void, Failure>> deleteProduct(int productId) =>
      _api.delete<void>('$_base/products/$productId', parser: (_) {});

  Future<Result<List<InventoryIngredientEntity>, Failure>> getInventory() =>
      _api.get<List<InventoryIngredientEntity>>(
        '$_base/inventory',
        parser: (raw) => (raw as List<dynamic>)
            .map((e) => InventoryIngredientModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList(),
      );

  Future<Result<void, Failure>> updateStock({
    required int ingredientId, required double newQuantity, String? reason,
  }) => _api.put<void>(
    '$_base/inventory/$ingredientId/stock',
    data: {'quantity': newQuantity, if (reason != null) 'reason': reason},
    parser: (_) {},
  );

  Future<Result<AdminReportEntity, Failure>> getReports({
    required String reportType, String? dateFrom, String? dateTo,
  }) => _api.get<AdminReportEntity>(
    '$_base/reports',
    query: {
      'type': reportType,
      if (dateFrom != null) 'from': dateFrom,
      if (dateTo != null) 'to': dateTo,
    },
    parser: (raw) => AdminReportModel.fromJson(raw as Map<String, dynamic>),
  );

  Future<Result<PaginatedResponse<AdminStaffEntity>, Failure>> listStaff({
    int page = 1, int pageSize = 20,
  }) => _api.get<PaginatedResponse<AdminStaffEntity>>(
    '$_base/staff',
    query: {'page': page, 'pageSize': pageSize},
    parser: _parsePaginated((raw) => AdminStaffModel.fromJson(raw as Map<String, dynamic>).toEntity()),
  );

  Future<Result<AdminStaffEntity, Failure>> createStaff(Map<String, dynamic> body) =>
      _api.post<AdminStaffEntity>(
        '$_base/staff',
        data: body,
        parser: (raw) => AdminStaffModel.fromJson(raw as Map<String, dynamic>).toEntity(),
      );

  Future<Result<PaginatedResponse<AdminCouponEntity>, Failure>> listCoupons({
    int page = 1, int pageSize = 20,
  }) => _api.get<PaginatedResponse<AdminCouponEntity>>(
    '$_base/coupons',
    query: {'page': page, 'pageSize': pageSize},
    parser: _parsePaginated((raw) => AdminCouponModel.fromJson(raw as Map<String, dynamic>).toEntity()),
  );

  Future<Result<AdminCouponEntity, Failure>> createCoupon(Map<String, dynamic> body) =>
      _api.post<AdminCouponEntity>(
        '$_base/coupons',
        data: body,
        parser: (raw) => AdminCouponModel.fromJson(raw as Map<String, dynamic>).toEntity(),
      );

  Future<Result<void, Failure>> deleteCoupon(int couponId) =>
      _api.delete<void>('$_base/coupons/$couponId', parser: (_) {});
}

PaginatedResponse<T> Function(dynamic) _parsePaginated<T>(T Function(Map<String, dynamic>) itemParser) {
  return (raw) {
    final json = raw as Map<String, dynamic>;
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  };
}