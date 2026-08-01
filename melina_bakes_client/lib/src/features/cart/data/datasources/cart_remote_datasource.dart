
/// Remote data source for cart API calls.
library;

import '../../../../core/network/api_client.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

abstract interface class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartItemModel> addItem({required int productId, required int quantity, Map<String, dynamic>? attributes});
  Future<CartItemModel> updateItemQuantity({required int itemId, required int quantity});
  Future<void> removeItem(int itemId);
  Future<void> clearCart();
  Future<CartModel> applyCoupon(String code);
  Future<CartModel> removeCoupon();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;
  CartRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CartModel> getCart() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/cart',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => CartModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<CartItemModel> addItem({required int productId, required int quantity, Map<String, dynamic>? attributes}) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/cart/items',
      parser: (data) => data as Map<String, dynamic>,
      data: {'productId': productId, 'quantity': quantity, if (attributes != null) 'attributes': attributes},
    );
    return result.when(
      success: (data) => CartItemModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<CartItemModel> updateItemQuantity({required int itemId, required int quantity}) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      '/cart/items/$itemId',
      parser: (data) => data as Map<String, dynamic>,
      data: {'quantity': quantity},
    );
    return result.when(
      success: (data) => CartItemModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<void> removeItem(int itemId) async {
    final result = await _apiClient.delete<void>(
      '/cart/items/$itemId',
      parser: (_) {},
    );
    result.when(success: (_) {}, failure: (f) => throw Exception(f.message));
  }

  @override
  Future<void> clearCart() async {
    final result = await _apiClient.delete<void>(
      '/cart',
      parser: (_) {},
    );
    result.when(success: (_) {}, failure: (f) => throw Exception(f.message));
  }

  @override
  Future<CartModel> applyCoupon(String code) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/cart/apply-coupon',
      parser: (data) => data as Map<String, dynamic>,
      data: {'code': code},
    );
    return result.when(
      success: (data) => CartModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<CartModel> removeCoupon() async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/cart/remove-coupon',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => CartModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }
}
