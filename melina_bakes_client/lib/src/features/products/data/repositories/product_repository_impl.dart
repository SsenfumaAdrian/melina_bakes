
/// Implementation of [ProductRepository].
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  ProductRepositoryImpl(this._remote);

  @override
  Future<Result<PaginatedResponse<ProductEntity>, Failure>> getProducts({
    int page = 1, int pageSize = 20, String? categorySlug, String? searchQuery,
    double? minPrice, double? maxPrice, String? sortBy, bool sortDescending = false,
    bool? isFeatured, bool? isNew,
  }) async {
    try {
      final result = await _remote.getProducts(
        page: page, pageSize: pageSize, categorySlug: categorySlug,
        searchQuery: searchQuery, minPrice: minPrice, maxPrice: maxPrice,
        sortBy: sortBy, sortDescending: sortDescending,
        isFeatured: isFeatured, isNew: isNew,
      );
      return Success(result.map((m) => m.toEntity()));
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity, Failure>> getProductBySlug(String slug) async {
    try {
      final model = await _remote.getProductBySlug(slug);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CategoryEntity>, Failure>> getCategories() async {
    try {
      final models = await _remote.getCategories();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CategoryEntity, Failure>> getCategoryBySlug(String slug) async {
    try {
      final model = await _remote.getCategoryBySlug(slug);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEntity>, Failure>> getFeaturedProducts({int limit = 8}) async {
    try {
      final models = await _remote.getFeaturedProducts(limit: limit);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEntity>, Failure>> getRelatedProducts(String slug, {int limit = 4}) async {
    try {
      final models = await _remote.getRelatedProducts(slug, limit: limit);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<String>, Failure>> getSearchSuggestions(String query) async {
    try {
      final suggestions = await _remote.getSearchSuggestions(query);
      return Success(suggestions);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }
}
