/// Customer Dashboard API Endpoint
///
/// Handles customer profile, addresses, orders, wishlist,
/// and notifications.
///
/// Routes:
/// - GET /customer/profile
/// - PUT /customer/profile
/// - GET /customer/addresses
/// - POST /customer/addresses
/// - PUT /customer/addresses/:id
/// - DELETE /customer/addresses/:id
/// - GET /customer/orders
/// - GET /customer/wishlist
/// - POST /customer/wishlist
/// - DELETE /customer/wishlist/:id
/// - GET /customer/notifications
/// - PUT /customer/notifications/:id/read
import 'package:serverpod/serverpod.dart';

class CustomerEndpoint extends Endpoint {
  /// GET /customer/profile
  Future<Map<String, dynamic>> getProfile(Session session) async {
    return {
      'success': true,
      'data': {
        'id': 1,
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+1234567890',
        'avatarUrl': '/images/avatars/default.jpg',
        'role': 'customer',
        'isEmailVerified': true,
        'memberSince': '2024-01-15T00:00:00Z',
        'totalOrders': 24,
        'totalSpent': 1245.50,
      },
    };
  }

  /// PUT /customer/profile
  Future<Map<String, dynamic>> updateProfile(
    Session session, {
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    return {
      'success': true,
      'message': 'Profile updated successfully',
      'data': {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
      },
    };
  }

  /// GET /customer/addresses
  Future<Map<String, dynamic>> listAddresses(Session session) async {
    return {
      'success': true,
      'data': [
        {
          'id': 1,
          'label': 'Home',
          'recipientName': 'John Doe',
          'phoneNumber': '+1234567890',
          'streetAddress': '123 Bakery Lane',
          'apartment': '4B',
          'city': 'New York',
          'state': 'NY',
          'postalCode': '10001',
          'country': 'USA',
          'isDefault': true,
        },
        {
          'id': 2,
          'label': 'Office',
          'recipientName': 'John Doe',
          'phoneNumber': '+1234567890',
          'streetAddress': '456 Business Ave',
          'apartment': 'Suite 200',
          'city': 'New York',
          'state': 'NY',
          'postalCode': '10002',
          'country': 'USA',
          'isDefault': false,
        },
      ],
    };
  }

  /// POST /customer/addresses
  Future<Map<String, dynamic>> createAddress(
    Session session, {
    required String streetAddress,
    required String city,
    required String country,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? apartment,
    String? state,
    String? postalCode,
    bool isDefault = false,
  }) async {
    return {
      'success': true,
      'message': 'Address added successfully',
      'data': {
        'id': 3,
        'label': label ?? 'Address',
        'streetAddress': streetAddress,
        'city': city,
        'country': country,
        'isDefault': isDefault,
      },
    };
  }

  /// PUT /customer/addresses/:id
  Future<Map<String, dynamic>> updateAddress(
    Session session, {
    required int addressId,
    String? label,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) async {
    return {
      'success': true,
      'message': 'Address updated',
    };
  }

  /// DELETE /customer/addresses/:id
  Future<Map<String, dynamic>> deleteAddress(
    Session session, {
    required int addressId,
  }) async {
    return {
      'success': true,
      'message': 'Address deleted',
    };
  }

  /// GET /customer/orders
  Future<Map<String, dynamic>> listCustomerOrders(
    Session session, {
    int page = 1,
    int pageSize = 10,
  }) async {
    return {
      'success': true,
      'data': {
        'items': [
          {
            'id': 1001,
            'orderNumber': 'MB-20260801-1001',
            'status': 'preparing',
            'total': 102.08,
            'itemCount': 3,
            'createdAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          },
        ],
        'page': page,
        'pageSize': pageSize,
        'totalItems': 1,
        'totalPages': 1,
      },
    };
  }

  /// GET /customer/wishlist
  Future<Map<String, dynamic>> listWishlist(Session session) async {
    return {
      'success': true,
      'data': [
        {
          'id': 1,
          'product': {
            'id': 5,
            'name': 'Red Velvet Cake',
            'slug': 'red-velvet-cake',
            'basePrice': 42.99,
            'primaryImageUrl': '/images/products/red-velvet-cake.jpg',
            'status': 'available',
          },
          'addedAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        },
      ],
    };
  }

  /// POST /customer/wishlist
  Future<Map<String, dynamic>> addToWishlist(
    Session session, {
    required int productId,
  }) async {
    return {
      'success': true,
      'message': 'Added to wishlist',
    };
  }

  /// DELETE /customer/wishlist/:id
  Future<Map<String, dynamic>> removeFromWishlist(
    Session session, {
    required int wishlistItemId,
  }) async {
    return {
      'success': true,
      'message': 'Removed from wishlist',
    };
  }

  /// GET /customer/notifications
  Future<Map<String, dynamic>> listNotifications(
    Session session, {
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    return {
      'success': true,
      'data': {
        'items': [
          {
            'id': 1,
            'type': 'orderUpdate',
            'title': 'Order Update',
            'body': 'Your order MB-20260801-1001 is now being prepared.',
            'readAt': null,
            'createdAt': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
          },
          {
            'id': 2,
            'type': 'promotion',
            'title': 'Weekend Special',
            'body': 'Get 20% off all cakes this weekend!',
            'readAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
            'createdAt': DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
          },
        ],
        'unreadCount': 1,
        'page': page,
        'pageSize': pageSize,
      },
    };
  }

  /// PUT /customer/notifications/:id/read
  Future<Map<String, dynamic>> markNotificationRead(
    Session session, {
    required int notificationId,
  }) async {
    return {
      'success': true,
      'message': 'Notification marked as read',
    };
  }
}
