
/// Repository contract for shopping cart operations.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';

abstract interface class CartRepository {
  /// Gets the current user's cart.
  Future<Result<CartEntity, Failure>> getCart();

  /// Adds a product to the cart.
  Future<Result<CartItemEntity, Failure>> addItem({
    required int productId,
    required int quantity,
    Map<String, dynamic>? attributes,
  });

  /// Updates the quantity of a cart item.
  Future<Result<CartItemEntity, Failure>> updateItemQuantity({
    required int itemId,
    required int quantity,
  });

  /// Removes an item from the cart.
  Future<Result<void, Failure>> removeItem(int itemId);

  /// Clears all items from the cart.
  Future<Result<void, Failure>> clearCart();

  /// Applies a coupon code to the cart.
  Future<Result<CartEntity, Failure>> applyCoupon(String code);

  /// Removes the applied coupon.
  Future<Result<CartEntity, Failure>> removeCoupon();
}
