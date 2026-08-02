
/// Remote data source for order management API calls.
///
/// Wraps every endpoint exposed by the server's `OrdersEndpoint` and
/// translates the `Result<T, Failure>` envelope from the [ApiClient]
/// into raw models, surfacing failures as exceptions for the repository
/// layer to map back into [Failure] objects.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_cancellation_model.dart';
import '../models/order_list_item_model.dart';
import '../models/order_model.dart';
import '../models/order_tracking_model.dart';

abstract interface class OrderRemoteDataSource {
  Future<PaginatedResponse<OrderListItemModel>> listOrders({
    int page,
    int pageSize,
    OrderStatus? statusFilter,
  });

  Future<OrderModel> getOrderByNumber(String orderNumber);
  Future<OrderTrackingModel> trackOrder(String orderNumber);

  Future<OrderModel> createOrder({
    required int cartId,
    required int deliveryAddressId,
    String deliveryMethod,
    String? customerNotes,
    String? paymentMethod,
  });

  Future<OrderCancellationModel> cancelOrder({
    required int orderId,
    String? reason,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  OrderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<OrderListItemModel>> listOrders({
    int page = 1,
    int pageSize = 10,
    OrderStatus? statusFilter,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/orders',
      parser: (data) => data as Map<String, dynamic>,
      query: {
        'page': page,
        'pageSize': pageSize,
        if (statusFilter != null) 'statusFilter': statusFilter.name,
      },
    );
    return result.when(
      success: (data) {
        final items = (data['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderListItemModel.fromJson(e))
            .toList();
        return PaginatedResponse<OrderListItemModel>(
          items: items,
          page: data['page'] as int? ?? page,
          pageSize: data['pageSize'] as int? ?? pageSize,
          totalItems: data['totalItems'] as int? ?? items.length,
          totalPages: data['totalPages'] as int? ?? 1,
          hasNextPage: data['hasNextPage'] as bool? ?? false,
          hasPreviousPage: data['hasPreviousPage'] as bool? ?? false,
        );
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<OrderModel> getOrderByNumber(String orderNumber) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/orders/$orderNumber',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => OrderModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<OrderTrackingModel> trackOrder(String orderNumber) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/orders/$orderNumber/track',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => OrderTrackingModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<OrderModel> createOrder({
    required int cartId,
    required int deliveryAddressId,
    String deliveryMethod = 'standard',
    String? customerNotes,
    String? paymentMethod,
  }) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/orders',
      parser: (data) => data as Map<String, dynamic>,
      data: {
        'cartId': cartId,
        'deliveryAddressId': deliveryAddressId,
        'deliveryMethod': deliveryMethod,
        if (customerNotes != null) 'customerNotes': customerNotes,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      },
    );
    return result.when(
      success: (data) {
        // The create endpoint nests the order under the `order` key.
        final nested = data['order'] as Map<String, dynamic>?;
        if (nested != null) return OrderModel.fromJson(nested);
        return OrderModel.fromJson(data);
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<OrderCancellationModel> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/orders/$orderId/cancel',
      parser: (data) => data as Map<String, dynamic>,
      data: {if (reason != null) 'reason': reason},
    );
    return result.when(
      success: (data) => OrderCancellationModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }
}
