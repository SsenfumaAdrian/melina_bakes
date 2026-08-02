library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/admin_coupon_entity.dart';
import '../../domain/entities/admin_customer_entity.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/admin_order_list_item_entity.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/entities/admin_staff_entity.dart';
import '../../domain/entities/inventory_ingredient_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;
  AdminRepositoryImpl(this._remote);

  @override
  Future<Result<AdminDashboardEntity, Failure>> getDashboardStats() => _remote.getDashboardStats();

  @override
  Future<Result<PaginatedResponse<AdminOrderListItemEntity>, Failure>> listOrders({
    int page = 1, int pageSize = 20,
    String? statusFilter, String? paymentStatusFilter,
    String? dateFrom, String? dateTo, String? searchQuery,
  }) => _remote.listOrders(
    page: page, pageSize: pageSize, statusFilter: statusFilter,
    paymentStatusFilter: paymentStatusFilter, dateFrom: dateFrom, dateTo: dateTo,
    searchQuery: searchQuery,
  );

  @override
  Future<Result<void, Failure>> updateOrderStatus({
    required int orderId, required String newStatus, String? reason,
  }) => _remote.updateOrderStatus(orderId: orderId, newStatus: newStatus, reason: reason);

  @override
  Future<Result<PaginatedResponse<AdminCustomerEntity>, Failure>> listCustomers({
    int page = 1, int pageSize = 20, String? searchQuery,
  }) => _remote.listCustomers(page: page, pageSize: pageSize, searchQuery: searchQuery);

  @override
  Future<Result<PaginatedResponse<AdminProductEntity>, Failure>> listProducts({
    int page = 1, int pageSize = 20, String? statusFilter, String? searchQuery,
  }) => _remote.listProducts(page: page, pageSize: pageSize, statusFilter: statusFilter, searchQuery: searchQuery);

  @override
  Future<Result<AdminProductEntity, Failure>> createProduct({
    required String name, required String slug, required String sku,
    required int categoryId, required double basePrice, double? salePrice,
    double? costPrice, String? description, String? primaryImageUrl,
    int quantityInStock = 0, bool trackInventory = true,
    String status = 'available', bool isFeatured = false,
  }) => _remote.createProduct({
    'name': name, 'slug': slug, 'sku': sku, 'categoryId': categoryId,
    'basePrice': basePrice, if (salePrice != null) 'salePrice': salePrice,
    if (costPrice != null) 'costPrice': costPrice, if (description != null) 'description': description,
    if (primaryImageUrl != null) 'primaryImageUrl': primaryImageUrl,
    'quantityInStock': quantityInStock, 'trackInventory': trackInventory,
    'status': status, 'isFeatured': isFeatured,
  });

  @override
  Future<Result<void, Failure>> updateProduct({
    required int productId, String? name, String? slug, double? basePrice,
    double? salePrice, int? quantityInStock, String? status, bool? isFeatured,
  }) => _remote.updateProduct(
    productId: productId,
    body: {
      if (name != null) 'name': name, if (slug != null) 'slug': slug,
      if (basePrice != null) 'basePrice': basePrice, if (salePrice != null) 'salePrice': salePrice,
      if (quantityInStock != null) 'quantityInStock': quantityInStock,
      if (status != null) 'status': status, if (isFeatured != null) 'isFeatured': isFeatured,
    },
  );

  @override
  Future<Result<void, Failure>> deleteProduct(int productId) => _remote.deleteProduct(productId);

  @override
  Future<Result<List<InventoryIngredientEntity>, Failure>> getInventory() => _remote.getInventory();

  @override
  Future<Result<void, Failure>> updateStock({
    required int ingredientId, required double newQuantity, String? reason,
  }) => _remote.updateStock(ingredientId: ingredientId, newQuantity: newQuantity, reason: reason);

  @override
  Future<Result<AdminReportEntity, Failure>> getReports({
    required String reportType, String? dateFrom, String? dateTo,
  }) => _remote.getReports(reportType: reportType, dateFrom: dateFrom, dateTo: dateTo);

  @override
  Future<Result<PaginatedResponse<AdminStaffEntity>, Failure>> listStaff({
    int page = 1, int pageSize = 20,
  }) => _remote.listStaff(page: page, pageSize: pageSize);

  @override
  Future<Result<AdminStaffEntity, Failure>> createStaff({
    required String email, required String firstName, required String lastName,
    required String role, String? department, String? position,
  }) => _remote.createStaff({
    'email': email, 'firstName': firstName, 'lastName': lastName, 'role': role,
    if (department != null) 'department': department, if (position != null) 'position': position,
  });

  @override
  Future<Result<PaginatedResponse<AdminCouponEntity>, Failure>> listCoupons({
    int page = 1, int pageSize = 20,
  }) => _remote.listCoupons(page: page, pageSize: pageSize);

  @override
  Future<Result<AdminCouponEntity, Failure>> createCoupon({
    required String code, String? description, required String type,
    required double value, double? minOrderAmount, String? startsAt,
    String? endsAt, int? usageLimit,
  }) => _remote.createCoupon({
    'code': code, if (description != null) 'description': description, 'type': type,
    'value': value, if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
    if (startsAt != null) 'startsAt': startsAt, if (endsAt != null) 'endsAt': endsAt,
    if (usageLimit != null) 'usageLimit': usageLimit,
  });

  @override
  Future<Result<void, Failure>> deleteCoupon(int couponId) => _remote.deleteCoupon(couponId);
}