
/// Repository contract for the order management feature.
///
/// Defines all order operations the presentation layer can request.
/// Every method returns a [Result] forcing explicit error handling
/// at the call site.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../entities/order_cancellation_entity.dart';
import '../entities/order_entity.dart';
import '../entities/order_list_item_entity.dart';
import '../entities/order_tracking_entity.dart';

abstract interface class OrderRepository {
  /// Lists the authenticated user's orders with pagination and an
  /// optional status filter.
  Future<Result<PaginatedResponse<OrderListItemEntity>, Failure>> listOrders({
    int page,
    int pageSize,
    OrderStatus? statusFilter,
  });

  /// Fetches the full order detail for the given [orderNumber].
  Future<Result<OrderEntity, Failure>> getOrderByNumber(String orderNumber);

  /// Fetches real-time tracking information for the given [orderNumber].
  Future<Result<OrderTrackingEntity, Failure>> trackOrder(String orderNumber);

  /// Creates a new order from the current cart.
  ///
  /// Returns the newly created order on success.
  Future<Result<OrderEntity, Failure>> createOrder({
    required int cartId,
    required int deliveryAddressId,
    String deliveryMethod,
    String? customerNotes,
    String? paymentMethod,
  });

  /// Cancels an order by its server-assigned [orderId].
  ///
  /// Only cancellable orders (pending or confirmed) can be cancelled.
  Future<Result<OrderCancellationEntity, Failure>> cancelOrder({
    required int orderId,
    String? reason,
  });
}
