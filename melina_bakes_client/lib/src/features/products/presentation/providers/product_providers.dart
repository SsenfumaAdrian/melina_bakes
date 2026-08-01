
/// Riverpod providers for the product catalog feature.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';

/// Provider for the product remote data source.
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>(
  (ref) => ProductRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

/// Provider for the product repository.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productRemoteDataSourceProvider)),
);

/// ─── Categories ───

/// Async provider that fetches all categories.
final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getCategories();
  return result.when(
    success: (cats) => cats,
    failure: (f) => throw Exception(f.message),
  );
});

/// ─── Product List ───

/// Filter state for product listing.
class ProductFilter {
  final String? categorySlug;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final bool sortDescending;
  final bool? isFeatured;
  final bool? isNew;

  const ProductFilter({
    this.categorySlug,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortDescending = false,
    this.isFeatured,
    this.isNew,
  });

  ProductFilter copyWith({
    String? categorySlug,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? sortDescending,
    bool? isFeatured,
    bool? isNew,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearPrice = false,
  }) {
    return ProductFilter(
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
    );
  }
}

/// State notifier for product list with pagination.
class ProductListNotifier extends StateNotifier<AsyncValue<PaginatedResponse<ProductEntity>>> {
  final ProductRepository _repository;
  ProductFilter _filter;
  int _currentPage = 1;
  static const int _pageSize = 20;

  ProductListNotifier(this._repository, this._filter)
      : super(const AsyncValue.loading()) {
    loadProducts();
  }

  ProductFilter get filter => _filter;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) _currentPage = 1;
    if (_currentPage == 1) state = const AsyncValue.loading();

    final result = await _repository.getProducts(
      page: _currentPage,
      pageSize: _pageSize,
      categorySlug: _filter.categorySlug,
      searchQuery: _filter.searchQuery,
      minPrice: _filter.minPrice,
      maxPrice: _filter.maxPrice,
      sortBy: _filter.sortBy,
      sortDescending: _filter.sortDescending,
      isFeatured: _filter.isFeatured,
      isNew: _filter.isNew,
    );

    result.when(
      success: (paginated) {
        if (_currentPage == 1 || refresh) {
          state = AsyncValue.data(paginated);
        } else {
          final current = state.valueOrNull;
          if (current != null) {
            state = AsyncValue.data(PaginatedResponse<ProductEntity>(
              items: [...current.items, ...paginated.items],
              page: paginated.page,
              pageSize: paginated.pageSize,
              totalItems: paginated.totalItems,
              totalPages: paginated.totalPages,
              hasNextPage: paginated.hasNextPage,
              hasPreviousPage: paginated.hasPreviousPage,
            ));
          } else {
            state = AsyncValue.data(paginated);
          }
        }
      },
      failure: (f) => state = AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNextPage) return;
    _currentPage++;
    await loadProducts();
  }

  void updateFilter(ProductFilter filter) {
    _filter = filter;
    _currentPage = 1;
    loadProducts(refresh: true);
  }

  void clearFilters() {
    _filter = const ProductFilter();
    _currentPage = 1;
    loadProducts(refresh: true);
  }
}

/// Provider for the product list notifier.
final productListProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<PaginatedResponse<ProductEntity>>>(
  (ref) => ProductListNotifier(ref.watch(productRepositoryProvider), const ProductFilter()),
);

/// ─── Product Detail ───

/// Async provider for a single product by slug.
final productDetailProvider = FutureProvider.family<ProductEntity, String>((ref, slug) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProductBySlug(slug);
  return result.when(
    success: (p) => p,
    failure: (f) => throw Exception(f.message),
  );
});

/// Async provider for related products.
final relatedProductsProvider = FutureProvider.family<List<ProductEntity>, String>((ref, slug) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getRelatedProducts(slug);
  return result.when(
    success: (p) => p,
    failure: (f) => throw Exception(f.message),
  );
});

/// ─── Featured Products ───

final featuredProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getFeaturedProducts(limit: 8);
  return result.when(
    success: (p) => p,
    failure: (f) => throw Exception(f.message),
  );
});

/// ─── Search ───

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getSearchSuggestions(query);
  return result.when(
    success: (s) => s,
    failure: (f) => [],
  );
});
