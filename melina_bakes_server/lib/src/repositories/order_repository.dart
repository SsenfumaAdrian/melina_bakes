/// Order Repository Interface
///
/// Contract for order management data access.
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../generated/order.dart';

abstract interface class OrderRepository {
  /// Creates a new order from a cart.
  Future<Result<Order, Failure>> createOrder({
    required int userId,
    required int cartId,
    required String orderNumber,
    required double subtotal,
    required double discountAmount,
    required double taxAmount,
    required double deliveryCharge,
    required double total,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    int? deliveryAddressId,
    String deliveryMethod = 'standard',
    String? couponCode,
    double couponDiscount = 0.0,
    String? customerNotes,
  });

  /// Finds an order by its unique order number.
  Future<Result<Order, Failure>> findByOrderNumber(String orderNumber);

  /// Finds an order by ID.
  Future<Result<Order, Failure>> findById(int id);

  /// Updates order status with audit trail.
  Future<Result<Order, Failure>> updateStatus({
    required int orderId,
    required OrderStatus newStatus,
    int? changedByUserId,
    UserRole? changedByRole,
    String? reason,
    String? ipAddress,
  });

  /// Lists orders for a user.
  Future<Result<PaginatedResponse<Order>, Failure>> listUserOrders({
    required int userId;
    required int page;
    required int pageSize;
    OrderStatus? statusFilter;
  });

  /// Lists all orders (admin).
  Future<Result<PaginatedResponse<Order>, Failure>> listAllOrders({
    required int page;
    required int pageSize;
    OrderStatus? statusFilter;
    PaymentStatus? paymentStatusFilter;
    DateTime? dateFrom;
    DateTime? dateTo;
    String? searchQuery;
  });

  /// Gets order statistics for dashboard.
  Future<Result<Map<String, dynamic>, Failure>> getOrderStats({
    DateTime? dateFrom;
    DateTime? dateTo;
  });
}
