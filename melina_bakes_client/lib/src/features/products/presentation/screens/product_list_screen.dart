
/// Product listing screen with grid layout, filters, and search.
///
/// Supports category filtering, price sorting, and infinite scroll.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_sheet.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? categorySlug;

  const ProductListScreen({super.key, this.categorySlug});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.categorySlug != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productListProvider.notifier).updateFilter(
          ProductFilter(categorySlug: widget.categorySlug),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _onSearch(String query) {
    ref.read(productListProvider.notifier).updateFilter(
      ProductFilter(searchQuery: query.isEmpty ? null : query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ProductFilterSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Category chips
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMd),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = widget.categorySlug == null &&
                        ref.read(productListProvider.notifier).filter.categorySlug == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: isSelected,
                        onSelected: (_) => ref.read(productListProvider.notifier).clearFilters(),
                      ),
                    );
                  }
                  final cat = categories[index - 1];
                  final isSelected = ref.read(productListProvider.notifier).filter.categorySlug == cat.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) => ref.read(productListProvider.notifier).updateFilter(
                        ProductFilter(categorySlug: cat.slug),
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 48, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: UIConstants.spacingSm),
          // Product grid
          Expanded(
            child: productsAsync.when(
              data: (paginated) {
                if (paginated.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No products found',
                    subtitle: 'Try adjusting your filters or search query',
                  );
                }
                return _ProductGrid(
                  products: paginated.items,
                  scrollController: _scrollController,
                  isLoadingMore: paginated.hasNextPage,
                );
              },
              loading: () => const LoadingIndicator(message: 'Loading products...'),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.read(productListProvider.notifier).loadProducts(refresh: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const _ProductGrid({
    required this.products,
    required this.scrollController,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return ProductCard(
              product: products[index],
              index: index,
            );
          },
        );
      },
    );
  }
}
