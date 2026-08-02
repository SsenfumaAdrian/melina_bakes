/// Riverpod providers for the admin dashboard feature.
///
/// Exposes repository wiring plus list/detail/mutation providers for:
/// dashboard, orders, customers, products, inventory, staff, coupons, reports.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/di/injection.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_coupon_entity.dart';
import '../../domain/entities/admin_customer_entity.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/admin_order_list_item_entity.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/entities/admin_staff_entity.dart';
import '../../domain/entities/inventory_ingredient_entity.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>(
  (ref) => AdminRemoteDataSource(ref.watch(apiClientProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(ref.watch(adminRemoteDataSourceProvider)),
);

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

final adminDashboardProvider = FutureProvider<AdminDashboardEntity>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getDashboardStats();
  return result.when(
    success: (dashboard) => dashboard,
    failure: (f) => throw Exception(f.message),
  );
});

// ---------------------------------------------------------------------------
// Orders
// ---------------------------------------------------------------------------

class AdminOrdersFilter {
  final int page;
  final int pageSize;
  final String? statusFilter;
  final String? searchQuery;
  const AdminOrdersFilter({this.page = 1, this.pageSize = 20, this.statusFilter, this.searchQuery});
  AdminOrdersFilter copyWith({
    int? page, int? pageSize, String? statusFilter, bool clearStatus = false,
    String? searchQuery, bool clearQuery = false,
  }) => AdminOrdersFilter(
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    searchQuery: clearQuery ? null : searchQuery ?? this.searchQuery,
  );
}

class AdminOrdersState {
  final List<AdminOrderListItemEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  final AdminOrdersFilter filter;
  const AdminOrdersState({
    this.items = const [], this.page = 1, this.pageSize = 20,
    this.hasNextPage = false, this.isLoading = false, this.isLoadingNext = false,
    this.error, this.filter = const AdminOrdersFilter(),
  });
  AdminOrdersState copyWith({
    List<AdminOrderListItemEntity>? items, int? page, int? pageSize,
    bool? hasNextPage, bool? isLoading, bool? isLoadingNext,
    Failure? error, bool clearError = false, AdminOrdersFilter? filter,
  }) => AdminOrdersState(
    items: items ?? this.items, page: page ?? this.page, pageSize: pageSize ?? this.pageSize,
    hasNextPage: hasNextPage ?? this.hasNextPage, isLoading: isLoading ?? this.isLoading,
    isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    error: clearError ? null : error ?? this.error, filter: filter ?? this.filter,
  );
}

class AdminOrdersController extends StateNotifier<AdminOrdersState> {
  final AdminRepository _repository;
  AdminOrdersController(this._repository) : super(const AdminOrdersState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listOrders(
      page: 1, pageSize: state.pageSize,
      statusFilter: state.filter.statusFilter, searchQuery: state.filter.searchQuery,
    );
    state = result.when(
      success: (page) => AdminOrdersState(
        items: page.items, page: page.page, pageSize: page.pageSize,
        hasNextPage: page.hasNextPage, isLoading: false, filter: state.filter,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;
    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listOrders(
      page: nextPage, pageSize: state.pageSize,
      statusFilter: state.filter.statusFilter, searchQuery: state.filter.searchQuery,
    );
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items], page: page.page,
        hasNextPage: page.hasNextPage, isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }

  Future<void> setStatusFilter(String? status) async {
    state = AdminOrdersState(
      pageSize: state.pageSize, isLoading: true,
      filter: state.filter.copyWith(clearStatus: true, statusFilter: status),
    );
    await refresh();
  }

  Future<void> setSearchQuery(String? query) async {
    state = AdminOrdersState(
      pageSize: state.pageSize, isLoading: true,
      filter: state.filter.copyWith(clearQuery: true, searchQuery: query),
    );
    await refresh();
  }

  Future<bool> updateOrderStatus({required int orderId, required String newStatus, String? reason}) async {
    final result = await _repository.updateOrderStatus(orderId: orderId, newStatus: newStatus, reason: reason);
    return result.when(success: (_) { refresh(); return true; }, failure: (_) => false);
  }
}

final adminOrdersProvider = StateNotifierProvider<AdminOrdersController, AdminOrdersState>(
  (ref) => AdminOrdersController(ref.watch(adminRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Customers
// ---------------------------------------------------------------------------

class AdminCustomersState {
  final List<AdminCustomerEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  final String? searchQuery;
  const AdminCustomersState({
    this.items = const [], this.page = 1, this.pageSize = 20,
    this.hasNextPage = false, this.isLoading = false, this.isLoadingNext = false,
    this.error, this.searchQuery,
  });
  AdminCustomersState copyWith({
    List<AdminCustomerEntity>? items, int? page, int? pageSize,
    bool? hasNextPage, bool? isLoading, bool? isLoadingNext,
    Failure? error, bool clearError = false, String? searchQuery, bool clearQuery = false,
  }) => AdminCustomersState(
    items: items ?? this.items, page: page ?? this.page, pageSize: pageSize ?? this.pageSize,
    hasNextPage: hasNextPage ?? this.hasNextPage, isLoading: isLoading ?? this.isLoading,
    isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    error: clearError ? null : error ?? this.error,
    searchQuery: clearQuery ? null : searchQuery ?? this.searchQuery,
  );
}

class AdminCustomersController extends StateNotifier<AdminCustomersState> {
  final AdminRepository _repository;
  AdminCustomersController(this._repository) : super(const AdminCustomersState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listCustomers(page: 1, pageSize: state.pageSize, searchQuery: state.searchQuery);
    state = result.when(
      success: (page) => AdminCustomersState(
        items: page.items, page: page.page, pageSize: page.pageSize,
        hasNextPage: page.hasNextPage, isLoading: false, searchQuery: state.searchQuery,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;
    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listCustomers(page: nextPage, pageSize: state.pageSize, searchQuery: state.searchQuery);
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items], page: page.page,
        hasNextPage: page.hasNextPage, isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }

  Future<void> setSearchQuery(String? query) async {
    state = AdminCustomersState(pageSize: state.pageSize, isLoading: true, searchQuery: query);
    await refresh();
  }
}

final adminCustomersProvider = StateNotifierProvider<AdminCustomersController, AdminCustomersState>(
  (ref) => AdminCustomersController(ref.watch(adminRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Products
// ---------------------------------------------------------------------------

class AdminProductsState {
  final List<AdminProductEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  final String? statusFilter;
  final String? searchQuery;
  const AdminProductsState({
    this.items = const [], this.page = 1, this.pageSize = 20,
    this.hasNextPage = false, this.isLoading = false, this.isLoadingNext = false,
    this.error, this.statusFilter, this.searchQuery,
  });
  AdminProductsState copyWith({
    List<AdminProductEntity>? items, int? page, int? pageSize,
    bool? hasNextPage, bool? isLoading, bool? isLoadingNext,
    Failure? error, bool clearError = false,
    String? statusFilter, bool clearStatus = false,
    String? searchQuery, bool clearQuery = false,
  }) => AdminProductsState(
    items: items ?? this.items, page: page ?? this.page, pageSize: pageSize ?? this.pageSize,
    hasNextPage: hasNextPage ?? this.hasNextPage, isLoading: isLoading ?? this.isLoading,
    isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    error: clearError ? null : error ?? this.error,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    searchQuery: clearQuery ? null : searchQuery ?? this.searchQuery,
  );
}

class AdminProductsController extends StateNotifier<AdminProductsState> {
  final AdminRepository _repository;
  AdminProductsController(this._repository) : super(const AdminProductsState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listProducts(
      page: 1, pageSize: state.pageSize,
      statusFilter: state.statusFilter, searchQuery: state.searchQuery,
    );
    state = result.when(
      success: (page) => AdminProductsState(
        items: page.items, page: page.page, pageSize: page.pageSize,
        hasNextPage: page.hasNextPage, isLoading: false,
        statusFilter: state.statusFilter, searchQuery: state.searchQuery,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;
    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listProducts(
      page: nextPage, pageSize: state.pageSize,
      statusFilter: state.statusFilter, searchQuery: state.searchQuery,
    );
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items], page: page.page,
        hasNextPage: page.hasNextPage, isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }

  Future<void> setStatusFilter(String? status) async {
    state = AdminProductsState(
      pageSize: state.pageSize, isLoading: true,
      statusFilter: status, searchQuery: state.searchQuery,
    );
    await refresh();
  }

  Future<void> setSearchQuery(String? query) async {
    state = AdminProductsState(
      pageSize: state.pageSize, isLoading: true,
      statusFilter: state.statusFilter, searchQuery: query,
    );
    await refresh();
  }

  Future<bool> toggleFeatured({required int productId, required bool isFeatured}) async {
    final result = await _repository.updateProduct(productId: productId, isFeatured: isFeatured);
    return result.when(success: (_) { refresh(); return true; }, failure: (_) => false);
  }

  Future<bool> deleteProduct(int productId) async {
    final result = await _repository.deleteProduct(productId);
    return result.when(success: (_) { refresh(); return true; }, failure: (_) => false);
  }
}

final adminProductsProvider = StateNotifierProvider<AdminProductsController, AdminProductsState>(
  (ref) => AdminProductsController(ref.watch(adminRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Inventory
// ---------------------------------------------------------------------------

final adminInventoryProvider = FutureProvider<List<InventoryIngredientEntity>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getInventory();
  return result.when(success: (items) => items, failure: (f) => throw Exception(f.message));
});

// ---------------------------------------------------------------------------
// Staff
// ---------------------------------------------------------------------------

class AdminStaffState {
  final List<AdminStaffEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  const AdminStaffState({
    this.items = const [], this.page = 1, this.pageSize = 20,
    this.hasNextPage = false, this.isLoading = false, this.isLoadingNext = false,
    this.error,
  });
  AdminStaffState copyWith({
    List<AdminStaffEntity>? items, int? page, int? pageSize,
    bool? hasNextPage, bool? isLoading, bool? isLoadingNext,
    Failure? error, bool clearError = false,
  }) => AdminStaffState(
    items: items ?? this.items, page: page ?? this.page, pageSize: pageSize ?? this.pageSize,
    hasNextPage: hasNextPage ?? this.hasNextPage, isLoading: isLoading ?? this.isLoading,
    isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    error: clearError ? null : error ?? this.error,
  );
}

class AdminStaffController extends StateNotifier<AdminStaffState> {
  final AdminRepository _repository;
  AdminStaffController(this._repository) : super(const AdminStaffState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listStaff(page: 1, pageSize: state.pageSize);
    state = result.when(
      success: (page) => AdminStaffState(
        items: page.items, page: page.page, pageSize: page.pageSize,
        hasNextPage: page.hasNextPage, isLoading: false,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;
    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listStaff(page: nextPage, pageSize: state.pageSize);
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items], page: page.page,
        hasNextPage: page.hasNextPage, isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }
}

final adminStaffProvider = StateNotifierProvider<AdminStaffController, AdminStaffState>(
  (ref) => AdminStaffController(ref.watch(adminRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Coupons
// ---------------------------------------------------------------------------

class AdminCouponsState {
  final List<AdminCouponEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  const AdminCouponsState({
    this.items = const [], this.page = 1, this.pageSize = 20,
    this.hasNextPage = false, this.isLoading = false, this.isLoadingNext = false,
    this.error,
  });
  AdminCouponsState copyWith({
    List<AdminCouponEntity>? items, int? page, int? pageSize,
    bool? hasNextPage, bool? isLoading, bool? isLoadingNext,
    Failure? error, bool clearError = false,
  }) => AdminCouponsState(
    items: items ?? this.items, page: page ?? this.page, pageSize: pageSize ?? this.pageSize,
    hasNextPage: hasNextPage ?? this.hasNextPage, isLoading: isLoading ?? this.isLoading,
    isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    error: clearError ? null : error ?? this.error,
  );
}

class AdminCouponsController extends StateNotifier<AdminCouponsState> {
  final AdminRepository _repository;
  AdminCouponsController(this._repository) : super(const AdminCouponsState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listCoupons(page: 1, pageSize: state.pageSize);
    state = result.when(
      success: (page) => AdminCouponsState(
        items: page.items, page: page.page, pageSize: page.pageSize,
        hasNextPage: page.hasNextPage, isLoading: false,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;
    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listCoupons(page: nextPage, pageSize: state.pageSize);
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items], page: page.page,
        hasNextPage: page.hasNextPage, isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }

  Future<AdminCouponEntity?> createCoupon({
    required String code, String? description, required String type,
    required double value, double? minOrderAmount, String? startsAt,
    String? endsAt, int? usageLimit,
  }) async {
    final result = await _repository.createCoupon(
      code: code, description: description, type: type, value: value,
      minOrderAmount: minOrderAmount, startsAt: startsAt, endsAt: endsAt, usageLimit: usageLimit,
    );
    return result.when(
      success: (coupon) { refresh(); return coupon; },
      failure: (_) => null,
    );
  }

  Future<bool> deleteCoupon(int couponId) async {
    final result = await _repository.deleteCoupon(couponId);
    return result.when(success: (_) { refresh(); return true; }, failure: (_) => false);
  }
}

final adminCouponsProvider = StateNotifierProvider<AdminCouponsController, AdminCouponsState>(
  (ref) => AdminCouponsController(ref.watch(adminRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class AdminReportsFilter {
  final String reportType;
  final String? dateFrom;
  final String? dateTo;
  const AdminReportsFilter({required this.reportType, this.dateFrom, this.dateTo});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReportsFilter &&
          other.reportType == reportType &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo;

  @override
  int get hashCode => Object.hash(reportType, dateFrom, dateTo);
}

final adminReportsProvider = FutureProvider.family<AdminReportEntity, AdminReportsFilter>(
  (ref, filter) async {
    final repo = ref.watch(adminRepositoryProvider);
    final result = await repo.getReports(reportType: filter.reportType, dateFrom: filter.dateFrom, dateTo: filter.dateTo);
    return result.when(success: (report) => report, failure: (f) => throw Exception(f.message));
  },
);