
/// Product detail screen with image gallery, info, reviews, and add-to-cart.
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
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));
    final relatedAsync = ref.watch(relatedProductsProvider(widget.slug));
    final theme = Theme.of(context);

    return Scaffold(
      body: productAsync.when(
        data: (product) => CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _ImageGallery(
                  product: product,
                  selectedIndex: _selectedImageIndex,
                  onImageSelected: (index) => setState(() => _selectedImageIndex = index),
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            // Product info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & badges
                    Row(
                      children: [
                        if (product.categoryName != null)
                          Chip(
                            label: Text(product.categoryName!),
                            backgroundColor: AppColors.primaryContainer,
                          ),
                        const SizedBox(width: 8),
                        if (product.isNew)
                          const Chip(
                            label: Text('NEW'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    // Name
                    Text(
                      product.name,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    // Rating
                    if (product.rating != null)
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final filled = i < (product.rating ?? 0).floor();
                            final half = i == (product.rating ?? 0).floor() &&
                                (product.rating ?? 0) % 1 >= 0.5;
                            return Icon(
                              half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
                              size: 20,
                              color: Colors.amber[600],
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (product.reviewCount != null)
                            Text(
                              ' (${product.reviewCount} reviews)',
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onLightMedium),
                            ),
                        ],
                      ),
                    const SizedBox(height: UIConstants.spacingLg),
                    // Price
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 12),
                          Text(
                            '\$${product.basePrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.onLightLow,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Save ${product.discountPercent}%',
                              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    // Description
                    if (product.description != null) ...[
                      Text('Description', style: theme.textTheme.titleLarge),
                      const SizedBox(height: UIConstants.spacingSm),
                      Text(
                        product.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onLightMedium),
                      ),
                      const SizedBox(height: UIConstants.spacingLg),
                    ],
                    // Allergens & Ingredients
                    if (product.allergens != null || product.ingredients != null)
                      _InfoSection(product: product),
                    const SizedBox(height: UIConstants.spacingLg),
                    // Stock status
                    Row(
                      children: [
                        Icon(
                          product.inStock ? Icons.check_circle : Icons.cancel,
                          color: product.inStock ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.inStock
                              ? 'In Stock (${product.quantityInStock} available)'
                              : 'Out of Stock',
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: product.inStock ? AppColors.success : AppColors.error,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingXl),
                    // Quantity selector
                    if (product.inStock) ...[
                      Text('Quantity', style: theme.textTheme.titleMedium),
                      const SizedBox(height: UIConstants.spacingSm),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              '$_quantity',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: _quantity < product.quantityInStock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingXl),
                    ],
                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: product.inStock ? () {} : null,
                        icon: const Icon(Icons.shopping_cart),
                        label: Text(product.inStock ? 'Add to Cart' : 'Out of Stock'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXl),
                    // Related products
                    relatedAsync.when(
                      data: (products) {
                        if (products.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('You May Also Like', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: UIConstants.spacingMd),
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                itemBuilder: (context, index) => SizedBox(
                                  width: 180,
                                  child: ProductCard(
                                    product: products[index],
                                    index: index,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: UIConstants.spacingXl),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const LoadingIndicator(message: 'Loading product...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(widget.slug)),
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final ProductEntity product;
  final int selectedIndex;
  final ValueChanged<int> onImageSelected;

  const _ImageGallery({
    required this.product,
    required this.selectedIndex,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : [if (product.primaryImageUrl != null) product.primaryImageUrl!];

    if (images.isEmpty) {
      return Container(
        color: AppColors.primaryContainer,
        child: const Center(
          child: Icon(Icons.cake, size: 80, color: AppColors.primary),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main image
        Image.network(
          images[selectedIndex],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primaryContainer,
            child: const Center(child: Icon(Icons.cake, size: 80, color: AppColors.primary)),
          ),
        ),
        // Thumbnail strip
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: images.asMap().entries.map((entry) {
                    final isSelected = entry.key == selectedIndex;
                    return GestureDetector(
                      onTap: () => onImageSelected(entry.key),
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.white : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final ProductEntity product;

  const _InfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.ingredients != null) ...[
          _InfoTile(
            icon: Icons.restaurant,
            title: 'Ingredients',
            content: product.ingredients!,
          ),
          const SizedBox(height: UIConstants.spacingMd),
        ],
        if (product.allergens != null) ...[
          _InfoTile(
            icon: Icons.warning_amber,
            title: 'Allergens',
            content: product.allergens!,
            isWarning: true,
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isWarning;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.content,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMd),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.error.withOpacity(0.05) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
        border: isWarning ? Border.all(color: AppColors.error.withOpacity(0.2)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isWarning ? AppColors.error : AppColors.primary, size: 20),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(content, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onLightMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
