/// Product Repository Interface
///
/// Contract for product catalog data access.
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../generated/product.dart';
import '../generated/category.dart';

abstract interface class ProductRepository {
  /// Creates a new product.
  Future<Result<Product, Failure>> createProduct({
    required int categoryId,
    required String name,
    required String slug,
    required String sku,
    required double basePrice,
    String? description,
    String? shortDescription,
    double? salePrice,
    double? costPrice,
    int quantityInStock = 0,
    int lowStockThreshold = 10,
    bool trackInventory = true,
    ProductStatus status = ProductStatus.available,
    bool isFeatured = false,
    String? primaryImageUrl,
    Map<String, dynamic>? attributes,
    double? weightGrams,
    String? allergens,
    String? ingredients,
  });

  /// Finds a product by its unique slug.
  Future<Result<Product, Failure>> findBySlug(String slug);

  /// Finds a product by its ID.
  Future<Result<Product, Failure>> findById(int id);

  /// Finds a product by SKU.
  Future<Result<Product, Failure>> findBySku(String sku);

  /// Updates product information.
  Future<Result<Product, Failure>> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? slug,
    String? description,
    double? basePrice,
    double? salePrice,
    int? quantityInStock,
    ProductStatus? status,
    bool? isFeatured,
    String? primaryImageUrl,
  });

  /// Updates product stock quantity.
  Future<Result<void, Failure>> updateStock({
    required int productId,
    required int newQuantity,
    required int userId,
    String? reason,
  });

  /// Lists products with filtering, sorting, and pagination.
  Future<Result<PaginatedResponse<Product>, Failure>> listProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    ProductStatus? status,
    bool? isFeatured,
    bool? isNew,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String? sortBy,
    bool sortDescending = false,
  });

  /// Gets featured products.
  Future<Result<List<Product>, Failure>> getFeatured({int limit = 10});

  /// Gets products with low stock.
  Future<Result<List<Product>, Failure>> getLowStock();

  /// Soft deletes a product.
  Future<Result<void, Failure>> softDelete(int productId);
}

abstract interface class CategoryRepository {
  /// Creates a new category.
  Future<Result<Category, Failure>> createCategory({
    required String name,
    required String slug,
    int? parentId,
    String? description,
    String? imageUrl,
    int sortOrder = 0,
    bool isFeatured = false,
  });

  /// Finds a category by slug.
  Future<Result<Category, Failure>> findBySlug(String slug);

  /// Finds a category by ID.
  Future<Result<Category, Failure>> findById(int id);

  /// Lists all active categories.
  Future<Result<List<Category>, Failure>> listCategories({
    bool includeInactive = false,
    int? parentId,
  });

  /// Updates a category.
  Future<Result<Category, Failure>> updateCategory({
    required int categoryId,
    String? name,
    String? slug,
    int? parentId,
    String? description,
    int? sortOrder,
    bool? isActive,
    bool? isFeatured,
  });

  /// Soft deletes a category.
  Future<Result<void, Failure>> softDelete(int categoryId);
}
