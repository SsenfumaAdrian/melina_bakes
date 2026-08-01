
/// Riverpod providers for the shopping cart feature.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';

/// Provider for the cart remote data source.
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>(
  (ref) => CartRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Provider for the cart repository.
final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(ref.watch(cartRemoteDataSourceProvider)),
);

/// Async provider that fetches the current cart.
final cartProvider = FutureProvider<CartEntity>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  final result = await repo.getCart();
  return result.when(
    success: (cart) => cart,
    failure: (f) => throw Exception(f.message),
  );
});

/// Provider that exposes the cart item count for the badge.
final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.when(
    data: (cart) => cart.totalQuantity,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// State notifier for cart operations with optimistic updates.
class CartController extends StateNotifier<AsyncValue<CartEntity>> {
  final CartRepository _repository;

  CartController(this._repository) : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCart();
    state = result.when(
      success: (cart) => AsyncValue.data(cart),
      failure: (f) => AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> addItem({required int productId, required int quantity, Map<String, dynamic>? attributes}) async {
    final currentCart = state.valueOrNull;
    if (currentCart == null) return;

    // Optimistic update not shown for simplicity — could add loading state per item
    final result = await _repository.addItem(productId: productId, quantity: quantity, attributes: attributes);
    result.when(
      success: (_) => loadCart(),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    if (quantity < 1) {
      await removeItem(itemId);
      return;
    }
    final result = await _repository.updateItemQuantity(itemId: itemId, quantity: quantity);
    result.when(
      success: (_) => loadCart(),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> removeItem(int itemId) async {
    final result = await _repository.removeItem(itemId);
    result.when(
      success: (_) => loadCart(),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> clearCart() async {
    final result = await _repository.clearCart();
    result.when(
      success: (_) => loadCart(),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> applyCoupon(String code) async {
    final result = await _repository.applyCoupon(code);
    result.when(
      success: (cart) => state = AsyncValue.data(cart),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> removeCoupon() async {
    final result = await _repository.removeCoupon();
    result.when(
      success: (cart) => state = AsyncValue.data(cart),
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }
}

/// Provider for the cart controller.
final cartControllerProvider = StateNotifierProvider<CartController, AsyncValue<CartEntity>>(
  (ref) => CartController(ref.watch(cartRepositoryProvider)),
);
