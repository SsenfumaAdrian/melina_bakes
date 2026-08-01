
/// Implementation of [CartRepository].
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remote;
  CartRepositoryImpl(this._remote);

  @override
  Future<Result<CartEntity, Failure>> getCart() async {
    try {
      final model = await _remote.getCart();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CartItemEntity, Failure>> addItem({required int productId, required int quantity, Map<String, dynamic>? attributes}) async {
    try {
      final model = await _remote.addItem(productId: productId, quantity: quantity, attributes: attributes);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CartItemEntity, Failure>> updateItemQuantity({required int itemId, required int quantity}) async {
    try {
      final model = await _remote.updateItemQuantity(itemId: itemId, quantity: quantity);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> removeItem(int itemId) async {
    try {
      await _remote.removeItem(itemId);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> clearCart() async {
    try {
      await _remote.clearCart();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CartEntity, Failure>> applyCoupon(String code) async {
    try {
      final model = await _remote.applyCoupon(code);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CartEntity, Failure>> removeCoupon() async {
    try {
      final model = await _remote.removeCoupon();
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }
}
