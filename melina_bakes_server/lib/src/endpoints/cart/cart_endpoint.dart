/// Shopping Cart API Endpoint
///
/// Handles cart operations: get, add, update, remove items,
/// apply/remove coupons, and calculate totals.
///
/// Routes:
/// - GET /cart
/// - POST /cart/items
/// - PUT /cart/items/:id
/// - DELETE /cart/items/:id
/// - POST /cart/apply-coupon
/// - POST /cart/remove-coupon
import 'package:serverpod/serverpod.dart';

class CartEndpoint extends Endpoint {
  /// GET /cart
  ///
  /// Gets the current user's cart with items and totals.
  Future<Map<String, dynamic>> getCart(Session session) async {
    return {
      'success': true,
      'data': {
        'id': 1,
        'items': [
          {
            'id': 1,
            'product': {
              'id': 1,
              'name': 'Chocolate Fudge Cake',
              'slug': 'chocolate-fudge-cake',
              'primaryImageUrl': '/images/products/chocolate-fudge-cake.jpg',
            },
            'quantity': 2,
            'unitPrice': 39.99,
            'totalPrice': 79.98,
            'specialInstructions': 'Write "Happy Birthday" on top',
          },
          {
            'id': 2,
            'product': {
              'id': 3,
              'name': 'Sourdough Bread',
              'slug': 'sourdough-bread',
              'primaryImageUrl': '/images/products/sourdough-bread.jpg',
            },
            'quantity': 1,
            'unitPrice': 8.99,
            'totalPrice': 8.99,
            'specialInstructions': null,
          },
        ],
        'subtotal': 88.97,
        'discountAmount': 0.00,
        'taxAmount': 7.12,
        'deliveryCharge': 5.99,
        'total': 102.08,
        'coupon': null,
        'itemCount': 3,
      },
    };
  }

  /// POST /cart/items
  ///
  /// Adds a product to the cart.
  Future<Map<String, dynamic>> addToCart(
    Session session, {
    required int productId,
    required int quantity,
    String? specialInstructions,
  }) async {
    if (quantity < 1) {
      return {
        'success': false,
        'error': {'code': 'INVALID_QUANTITY', 'message': 'Quantity must be at least 1'},
      };
    }

    return {
      'success': true,
      'message': 'Item added to cart',
      'data': {
        'cartItemId': 3,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': 39.99,
        'totalPrice': quantity * 39.99,
      },
    };
  }

  /// PUT /cart/items/:id
  ///
  /// Updates quantity of a cart item.
  Future<Map<String, dynamic>> updateCartItem(
    Session session, {
    required int itemId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      return {
        'success': false,
        'error': {'code': 'INVALID_QUANTITY', 'message': 'Quantity must be at least 1'},
      };
    }

    if (quantity == 0) {
      return removeFromCart(session, itemId: itemId);
    }

    return {
      'success': true,
      'message': 'Cart updated',
      'data': {
        'itemId': itemId,
        'quantity': quantity,
        'totalPrice': quantity * 39.99,
      },
    };
  }

  /// DELETE /cart/items/:id
  ///
  /// Removes an item from the cart.
  Future<Map<String, dynamic>> removeFromCart(
    Session session, {
    required int itemId,
  }) async {
    return {
      'success': true,
      'message': 'Item removed from cart',
    };
  }

  /// POST /cart/apply-coupon
  ///
  /// Applies a coupon code to the cart.
  Future<Map<String, dynamic>> applyCoupon(
    Session session, {
    required String code,
  }) async {
    // Validate coupon
    if (code.toUpperCase() == 'WELCOME10') {
      return {
        'success': true,
        'message': 'Coupon applied successfully',
        'data': {
          'code': 'WELCOME10',
          'type': 'percentage',
          'value': 10.0,
          'discountAmount': 8.90,
          'newTotal': 93.18,
        },
      };
    }

    return {
      'success': false,
      'error': {'code': 'INVALID_COUPON', 'message': 'Invalid or expired coupon code'},
    };
  }

  /// POST /cart/remove-coupon
  ///
  /// Removes the applied coupon from the cart.
  Future<Map<String, dynamic>> removeCoupon(Session session) async {
    return {
      'success': true,
      'message': 'Coupon removed',
    };
  }
}
