
/// Category detail screen showing products in a specific category.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const CategoryDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).updateFilter(
        ProductFilter(categorySlug: widget.slug),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryDetailProvider(widget.slug));
    final productsAsync = ref.watch(productListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: categoryAsync.when(
          data: (cat) => Text(cat.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Category'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: productsAsync.when(
        data: (paginated) {
          if (paginated.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bakery_dining, size: 64, color: AppColors.onLightLow),
                  const SizedBox(height: 16),
                  Text('No products in this category', style: theme.textTheme.headlineSmall),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: paginated.items.length,
            itemBuilder: (context, index) => ProductCard(
              product: paginated.items[index],
              index: index,
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading products...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.read(productListProvider.notifier).loadProducts(refresh: true),
        ),
      ),
    );
  }
}

final categoryDetailProvider = FutureProvider.family((ref, String slug) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getCategoryBySlug(slug);
  return result.when(
    success: (c) => c,
    failure: (f) => throw Exception(f.message),
  );
});
