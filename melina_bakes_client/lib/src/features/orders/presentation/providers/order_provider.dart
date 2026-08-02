/// Riverpod providers for the order management feature.
///
/// Exposes:
/// - [orderRemoteDataSourceProvider] / [orderRepositoryProvider] wiring.
/// - [ordersProvider]: paginated order list with an optional status filter.
/// - [orderDetailProvider]: family provider keyed by order number.
/// - [orderTrackingProvider]: family provider keyed by order number.
/// - [OrdersController]: state notifier performing create / cancel / refresh
///   operations and exposing the last completed order for navigation.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../cart/cart.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_cancellation_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_list_item_entity.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/repositories/order_repository.dart';

/// Provider for the order remote data source.
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>(
  (ref) => OrderRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Provider for the order repository.
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepositoryImpl(ref.watch(orderRemoteDataSourceProvider)),
);

/// Immutable filter state driving the order list query.
class OrderListFilter {
  final int page;
  final int pageSize;
  final OrderStatus? status;

  const OrderListFilter({
    this.page = 1,
    this.pageSize = 10,
    this.status,
  });

  OrderListFilter copyWith({int? page, int? pageSize, OrderStatus? status, bool clearStatus = false}) {
    return OrderListFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: clearStatus ? null : status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderListFilter &&
          other.page == page &&
          other.pageSize == pageSize &&
          other.status == status;

  @override
  int get hashCode => Object.hash(page, pageSize, status);
}

/// State of the [ordersProvider], accumulating pages of orders.
class OrdersState {
  final List<OrderListItemEntity> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingNext;
  final Failure? error;
  final OrderStatus? statusFilter;

  const OrdersState({
    this.items = const [],
    this.page = 1,
    this.pageSize = 10,
    this.hasNextPage = false,
    this.isLoading = false,
    this.isLoadingNext = false,
    this.error,
    this.statusFilter,
  });

  OrdersState copyWith({
    List<OrderListItemEntity>? items,
    int? page,
    int? pageSize,
    bool? hasNextPage,
    bool? isLoading,
    bool? isLoadingNext,
    Failure? error,
    bool clearError = false,
    OrderStatus? statusFilter,
    bool clearStatus = false,
  }) {
    return OrdersState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// Controller managing the paginated order list.
class OrdersController extends StateNotifier<OrdersState> {
  final OrderRepository _repository;

  OrdersController(this._repository) : super(const OrdersState(isLoading: true)) {
    refresh();
  }

  /// Reloads the first page from scratch using the current filter.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.listOrders(
      page: 1,
      pageSize: state.pageSize,
      statusFilter: state.statusFilter,
    );
    state = result.when(
      success: (page) => OrdersState(
        items: page.items,
        page: page.page,
        pageSize: page.pageSize,
        hasNextPage: page.hasNextPage,
        isLoading: false,
        statusFilter: state.statusFilter,
      ),
      failure: (f) => state.copyWith(isLoading: false, error: f),
    );
  }

  /// Loads the next page of results, appending items to the list.
  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingNext || !state.hasNextPage) return;

    state = state.copyWith(isLoadingNext: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await _repository.listOrders(
      page: nextPage,
      pageSize: state.pageSize,
      statusFilter: state.statusFilter,
    );
    state = result.when(
      success: (page) => state.copyWith(
        items: [...state.items, ...page.items],
        page: page.page,
        hasNextPage: page.hasNextPage,
        isLoadingNext: false,
      ),
      failure: (f) => state.copyWith(isLoadingNext: false, error: f),
    );
  }

  /// Sets the status filter and reloads the first page.
  Future<void> setStatusFilter(OrderStatus? status) async {
    state = OrdersState(
      pageSize: state.pageSize,
      isLoading: true,
      statusFilter: status,
    );
    await refresh();
  }
}

/// Provider for the orders list controller.
final ordersProvider = StateNotifierProvider<OrdersController, OrdersState>(
  (ref) => OrdersController(ref.watch(orderRepositoryProvider)),
);

/// Family provider that fetches a single order by its order number.
final orderDetailProvider =
    FutureProvider.family<OrderEntity, String>((ref, orderNumber) async {
  final repo = ref.watch(orderRepositoryProvider);
  final result = await repo.getOrderByNumber(orderNumber);
  return result.when(
    success: (order) => order,
    failure: (f) => throw Exception(f.message),
  );
});

/// Family provider that fetches live tracking information for an order.
final orderTrackingProvider =
    FutureProvider.family<OrderTrackingEntity, String>((ref, orderNumber) async {
  final repo = ref.watch(orderRepositoryProvider);
  final result = await repo.trackOrder(orderNumber);
  return result.when(
    success: (tracking) => tracking,
    failure: (f) => throw Exception(f.message),
  );
});

/// Outcome of an order mutation exposed to the presentation layer.
sealed class OrderMutationState {
  const OrderMutationState();
}

class OrderMutationIdle extends OrderMutationState {
  const OrderMutationIdle();
}

class OrderMutationLoading extends OrderMutationState {
  const OrderMutationLoading();
}

class OrderMutationCreated extends OrderMutationState {
  final OrderEntity order;
  const OrderMutationCreated(this.order);
}

class OrderMutationCancelled extends OrderMutationState {
  final OrderCancellationEntity cancellation;
  const OrderMutationCancelled(this.cancellation);
}

class OrderMutationFailure extends OrderMutationState {
  final String message;
  const OrderMutationFailure(this.message);
}

/// Controller responsible for create / cancel mutations on orders.
class OrderMutationController extends StateNotifier<OrderMutationState> {
  final OrderRepository _repository;
  final Ref _ref;

  OrderMutationController(this._repository, this._ref)
      : super(const OrderMutationIdle());

  /// Returns the cart id of the current user's cart, or null when the
  /// cart has not been loaded yet.
  int? _currentCartId() {
    final cartAsync = _ref.read(cartProvider);
    return cartAsync.maybeWhen(
      data: (cart) => cart.id,
      orElse: () => null,
    );
  }

  /// Creates a new order from the current cart.
  Future<OrderEntity?> createOrder({
    required int deliveryAddressId,
    String deliveryMethod = 'standard',
    String? customerNotes,
    String? paymentMethod,
  }) async {
    final cartId = _currentCartId();
    if (cartId == null) {
      state = const OrderMutationFailure('Your cart is not loaded yet.');
      return null;
    }

    state = const OrderMutationLoading();
    final result = await _repository.createOrder(
      cartId: cartId,
      deliveryAddressId: deliveryAddressId,
      deliveryMethod: deliveryMethod,
      customerNotes: customerNotes,
      paymentMethod: paymentMethod,
    );
    return result.when(
      success: (order) {
        state = OrderMutationCreated(order);
        _ref.invalidate(ordersProvider);
        _ref.invalidate(cartProvider);
        return order;
      },
      failure: (error) {
        state = OrderMutationFailure(error.message);
        return null;
      },
    );
  }

  /// Cancels an order by id. Returns the cancellation outcome or null.
  Future<OrderCancellationEntity?> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    state = const OrderMutationLoading();
    final result = await _repository.cancelOrder(
      orderId: orderId,
      reason: reason,
    );
    return result.when(
      success: (cancellation) {
        state = OrderMutationCancelled(cancellation);
        _ref.invalidate(ordersProvider);
        return cancellation;
      },
      failure: (error) {
        state = OrderMutationFailure(error.message);
        return null;
      },
    );
  }

  void reset() => state = const OrderMutationIdle();
}

/// Provider for the order mutation controller.
final orderMutationProvider =
    StateNotifierProvider<OrderMutationController, OrderMutationState>(
  (ref) => OrderMutationController(ref.watch(orderRepositoryProvider), ref),
);