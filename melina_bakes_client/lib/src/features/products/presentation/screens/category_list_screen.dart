
/// Category browsing screen with grid of category cards.
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
import '../providers/product_providers.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(UIConstants.pagePadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('${RouteNames.categories}/${cat.slug}'),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background
                      Container(
                        color: AppColors.primaryContainer,
                        child: cat.imageUrl != null
                            ? Image.network(cat.imageUrl!, fit: BoxFit.cover)
                            : const Center(child: Icon(Icons.bakery_dining, size: 48, color: AppColors.primary)),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                      // Text
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (cat.productCount > 0)
                              Text(
                                '${cat.productCount} products',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.white.withOpacity(0.8),
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.2, end: 0);
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading categories...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
      ),
    );
  }
}
