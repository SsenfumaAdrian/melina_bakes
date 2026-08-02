
/// Implementation of [OrderRepository].
///
/// Bridges the remote data source and the domain layer by mapping
/// every thrown exception into a typed [Failure], so the presentation
/// layer never receives exceptions.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/order_cancellation_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_list_item_entity.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  OrderRepositoryImpl(this._remote);

  @override
  Future<Result<PaginatedResponse<OrderListItemEntity>, Failure>> listOrders({
    int page = 1,
    int pageSize = 10,
    OrderStatus? statusFilter,
  }) async {
    try {
      final paginated = await _remote.listOrders(
        page: page,
        pageSize: pageSize,
        statusFilter: statusFilter,
      );
      final mapped = paginated.map((m) => m.toEntity());
      return Success(mapped);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<OrderEntity, Failure>> getOrderByNumber(String orderNumber) async {
    try {
      final model = await _remote.getOrderByNumber(orderNumber);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<OrderTrackingEntity, Failure>> trackOrder(String orderNumber) async {
    try {
      final model = await _remote.trackOrder(orderNumber);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<OrderEntity, Failure>> createOrder({
    required int cartId,
    required int deliveryAddressId,
    String deliveryMethod = 'standard',
    String? customerNotes,
    String? paymentMethod,
  }) async {
    try {
      final model = await _remote.createOrder(
        cartId: cartId,
        deliveryAddressId: deliveryAddressId,
        deliveryMethod: deliveryMethod,
        customerNotes: customerNotes,
        paymentMethod: paymentMethod,
      );
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<OrderCancellationEntity, Failure>> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    try {
      final model = await _remote.cancelOrder(orderId: orderId, reason: reason);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }
}
