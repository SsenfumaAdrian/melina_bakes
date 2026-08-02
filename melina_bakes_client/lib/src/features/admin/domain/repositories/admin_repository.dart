/// Repository contract for the admin dashboard feature.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../entities/admin_coupon_entity.dart';
import '../entities/admin_customer_entity.dart';
import '../entities/admin_dashboard_entity.dart';
import '../entities/admin_order_list_item_entity.dart';
import '../entities/admin_product_entity.dart';
import '../entities/admin_report_entity.dart';
import '../entities/admin_staff_entity.dart';
import '../entities/inventory_ingredient_entity.dart';

abstract interface class AdminRepository {
  Future<Result<AdminDashboardEntity, Failure>> getDashboardStats();

  Future<Result<PaginatedResponse<AdminOrderListItemEntity>, Failure>> listOrders({
    int page, int pageSize,
    String? statusFilter, String? paymentStatusFilter,
    String? dateFrom, String? dateTo, String? searchQuery,
  });

  Future<Result<void, Failure>> updateOrderStatus({
    required int orderId, required String newStatus, String? reason,
  });

  Future<Result<PaginatedResponse<AdminCustomerEntity>, Failure>> listCustomers({
    int page, int pageSize, String? searchQuery,
  });

  Future<Result<PaginatedResponse<AdminProductEntity>, Failure>> listProducts({
    int page, int pageSize, String? statusFilter, String? searchQuery,
  });

  Future<Result<AdminProductEntity, Failure>> createProduct({
    required String name, required String slug, required String sku,
    required int categoryId, required double basePrice, double? salePrice,
    double? costPrice, String? description, String? primaryImageUrl,
    int quantityInStock = 0, bool trackInventory = true,
    String status = 'available', bool isFeatured = false,
  });

  Future<Result<void, Failure>> updateProduct({
    required int productId, String? name, String? slug, double? basePrice,
    double? salePrice, int? quantityInStock, String? status, bool? isFeatured,
  });

  Future<Result<void, Failure>> deleteProduct(int productId);

  Future<Result<List<InventoryIngredientEntity>, Failure>> getInventory();
  Future<Result<void, Failure>> updateStock({required int ingredientId, required double newQuantity, String? reason});

  Future<Result<AdminReportEntity, Failure>> getReports({required String reportType, String? dateFrom, String? dateTo});

  Future<Result<PaginatedResponse<AdminStaffEntity>, Failure>> listStaff({int page, int pageSize});

  Future<Result<AdminStaffEntity, Failure>> createStaff({
    required String email, required String firstName, required String lastName,
    required String role, String? department, String? position,
  });

  Future<Result<PaginatedResponse<AdminCouponEntity>, Failure>> listCoupons({int page, int pageSize});
  Future<Result<AdminCouponEntity, Failure>> createCoupon({
    required String code, String? description, required String type,
    required double value, double? minOrderAmount, String? startsAt,
    String? endsAt, int? usageLimit,
  });
  Future<Result<void, Failure>> deleteCoupon(int couponId);
}