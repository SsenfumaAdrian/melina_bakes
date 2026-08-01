
/// Home screen for the Melina Bakes customer app.
///
/// Displays featured products, categories, promotions,
/// and a hero banner. Responsive across all screen sizes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner
          _HeroBanner(theme: theme),

          // Featured Categories
          _SectionTitle(title: 'Browse Categories', onSeeAll: () {}),
          const _CategoryGrid(),

          // Featured Products
          _SectionTitle(
            title: 'Featured Treats',
            onSeeAll: () => context.push(RouteNames.products),
          ),
          const _FeaturedProducts(),

          // Promotions Banner
          const _PromotionBanner(),

          // New Arrivals
          _SectionTitle(title: 'Fresh from the Oven', onSeeAll: () {}),
          const _NewArrivals(),

          const SizedBox(height: UIConstants.spacingXl),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final ThemeData theme;

  const _HeroBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingMd),
      padding: const EdgeInsets.all(UIConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadius),
      ),
      child: ResponsiveLayout(
        mobile: (_) => _buildMobileHero(context),
        tablet: (_) => _buildDesktopHero(context),
        desktop: (_) => _buildDesktopHero(context),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.bakery_dining,
          size: 48,
          color: AppColors.white.withOpacity(0.9),
        ),
        const SizedBox(height: UIConstants.spacingMd),
        Text(
          'Freshly Baked,\nJust for You',
          style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: UIConstants.spacingSm),
        Text(
          'Handcrafted with love using the finest ingredients. Order today and taste the difference.',
          style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
        ),
        const SizedBox(height: UIConstants.spacingLg),
        FilledButton.icon(
          onPressed: () => context.push(RouteNames.products),
          icon: const Icon(Icons.shopping_bag_outlined),
          label: const Text('Shop Now'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Freshly Baked, Just for You',
                style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Text(
                'Handcrafted with love using the finest ingredients.\nOrder today and taste the difference.',
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: UIConstants.spacingLg),
              FilledButton.icon(
                onPressed: () => context.push(RouteNames.products),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Shop Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: UIConstants.spacingXl),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cake,
            size: 100,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.pagePadding,
        vertical: UIConstants.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _categories = [
    {'name': 'Cakes', 'icon': Icons.cake},
    {'name': 'Pastries', 'icon': Icons.breakfast_dining},
    {'name': 'Bread', 'icon': Icons.bakery_dining},
    {'name': 'Cookies', 'icon': Icons.cookie},
    {'name': 'Specialty', 'icon': Icons.celebration},
    {'name': 'Seasonal', 'icon': Icons.auto_awesome},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryCard(
            name: category['name'] as String,
            icon: category['icon'] as IconData,
            index: index,
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final int index;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: UIConstants.spacingSm),
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.2, end: 0);
  }
}

class _FeaturedProducts extends StatelessWidget {
  const _FeaturedProducts();

  static const _products = [
    {'name': 'Chocolate Fudge Cake', 'price': 39.99, 'tag': 'Best Seller'},
    {'name': 'Vanilla Bean Cupcakes', 'price': 24.99, 'tag': 'New'},
    {'name': 'Sourdough Bread', 'price': 8.99, 'tag': null},
    {'name': 'Cinnamon Rolls (4)', 'price': 14.99, 'tag': 'Popular'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _ProductCard(
            name: product['name'] as String,
            price: product['price'] as double,
            tag: product['tag'] as String?,
            index: index,
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String? tag;
  final int index;

  const _ProductCard({
    required this.name,
    required this.price,
    this.tag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: UIConstants.spacingMd),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Expanded(
              child: Container(
                color: AppColors.primaryContainer,
                child: const Center(
                  child: Icon(Icons.cake, size: 48, color: AppColors.primary),
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(UIConstants.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null)
                    Chip(
                      label: Text(
                        tag!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primaryDark,
                            ),
                      ),
                      backgroundColor: AppColors.primaryContainer,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.2, end: 0);
  }
}

class _PromotionBanner extends StatelessWidget {
  const _PromotionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UIConstants.pagePadding),
      padding: const EdgeInsets.all(UIConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(UIConstants.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekend Special',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get 15% off all cakes this weekend. Use code SWEET15 at checkout.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onLightMedium,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _NewArrivals extends StatelessWidget {
  const _NewArrivals();

  static const _items = [
    {'name': 'Red Velvet Cake', 'price': 42.99},
    {'name': 'Lemon Tart', 'price': 18.99},
    {'name': 'Baguette', 'price': 5.99},
    {'name': 'Macarons (12)', 'price': 28.99},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final item = entry.value;
          return ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
              ),
              child: const Icon(Icons.bakery_dining, color: AppColors.primary),
            ),
            title: Text(item['name'] as String),
            subtitle: const Text('Freshly baked today'),
            trailing: Text(
              '\$${(item['price'] as double).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            onTap: () {},
          ).animate(delay: (entry.key * 60).ms).fadeIn().slideX(begin: -0.1, end: 0);
        }).toList(),
      ),
    );
  }
}
