
/// Remote data source for product catalog API calls.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page, int pageSize, String? categorySlug, String? searchQuery,
    double? minPrice, double? maxPrice, String? sortBy, bool sortDescending,
    bool? isFeatured, bool? isNew,
  });

  Future<ProductModel> getProductBySlug(String slug);
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryBySlug(String slug);
  Future<List<ProductModel>> getFeaturedProducts({int limit});
  Future<List<ProductModel>> getRelatedProducts(String slug, {int limit});
  Future<List<String>> getSearchSuggestions(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;
  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1, int pageSize = 20, String? categorySlug, String? searchQuery,
    double? minPrice, double? maxPrice, String? sortBy, bool sortDescending = false,
    bool? isFeatured, bool? isNew,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/products',
      parser: (data) => data as Map<String, dynamic>,
      query: {
        'page': page, 'pageSize': pageSize,
        if (categorySlug != null) 'categorySlug': categorySlug,
        if (searchQuery != null) 'searchQuery': searchQuery,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null) 'sortBy': sortBy,
        'sortDescending': sortDescending,
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (isNew != null) 'isNew': isNew,
      },
    );
    return result.when(
      success: (data) {
        final items = (data['items'] as List<dynamic>? ?? [])
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse<ProductModel>(
          items: items,
          page: data['page'] as int? ?? page,
          pageSize: data['pageSize'] as int? ?? pageSize,
          totalItems: data['totalItems'] as int? ?? items.length,
          totalPages: data['totalPages'] as int? ?? 1,
          hasNextPage: data['hasNextPage'] as bool? ?? false,
          hasPreviousPage: data['hasPreviousPage'] as bool? ?? false,
        );
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/products/$slug',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => ProductModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final result = await _apiClient.get<List<dynamic>>(
      '/categories',
      parser: (data) => data as List<dynamic>,
    );
    return result.when(
      success: (data) => data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<CategoryModel> getCategoryBySlug(String slug) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/categories/$slug',
      parser: (data) => data as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => CategoryModel.fromJson(data),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 8}) async {
    final result = await _apiClient.get<List<dynamic>>(
      '/products/featured',
      parser: (data) => data as List<dynamic>,
      query: {'limit': limit},
    );
    return result.when(
      success: (data) => data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(String slug, {int limit = 4}) async {
    final result = await _apiClient.get<List<dynamic>>(
      '/products/$slug/related',
      parser: (data) => data as List<dynamic>,
      query: {'limit': limit},
    );
    return result.when(
      success: (data) => data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (f) => throw Exception(f.message),
    );
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/products/search/suggestions',
      parser: (data) => data as Map<String, dynamic>,
      query: {'q': query},
    );
    return result.when(
      success: (data) => (data['suggestions'] as List<dynamic>? ?? []).cast<String>(),
      failure: (f) => throw Exception(f.message),
    );
  }
}
