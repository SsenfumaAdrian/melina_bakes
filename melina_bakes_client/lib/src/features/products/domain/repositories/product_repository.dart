
/// Repository contract for product catalog operations.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../entities/product_entity.dart';
import '../entities/category_entity.dart';

abstract interface class ProductRepository {
  Future<Result<PaginatedResponse<ProductEntity>, Failure>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categorySlug,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool sortDescending = false,
    bool? isFeatured,
    bool? isNew,
  });

  Future<Result<ProductEntity, Failure>> getProductBySlug(String slug);

  Future<Result<List<CategoryEntity>, Failure>> getCategories();

  Future<Result<CategoryEntity, Failure>> getCategoryBySlug(String slug);

  Future<Result<List<ProductEntity>, Failure>> getFeaturedProducts({int limit = 8});

  Future<Result<List<ProductEntity>, Failure>> getRelatedProducts(String slug, {int limit = 4});

  Future<Result<List<String>, Failure>> getSearchSuggestions(String query);
}
