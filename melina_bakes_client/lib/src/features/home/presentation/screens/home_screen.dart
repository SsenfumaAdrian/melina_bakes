
/// Home screen for the Melina Bakes customer app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../products/domain/entities/category_entity.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBanner(theme: theme),
          _SectionTitle(title: 'Browse Categories', onSeeAll: () => context.push(RouteNames.categories)),
          categoriesAsync.when(
            data: (cats) => _CategoryChips(categories: cats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          _SectionTitle(title: 'Featured Treats', onSeeAll: () => context.push(RouteNames.products)),
          featuredAsync.when(
            data: (products) => SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
                itemCount: products.length,
                itemBuilder: (context, index) => SizedBox(
                  width: 180,
                  child: ProductCard(product: products[index], index: index),
                ),
              ),
            ),
            loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const _PromotionBanner(),
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
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.bakery_dining, size: 48, color: AppColors.white),
        const SizedBox(height: UIConstants.spacingMd),
        Text('Freshly Baked,\nJust for You', style: theme.textTheme.headlineLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: UIConstants.spacingSm),
        Text('Handcrafted with love using the finest ingredients. Order today and taste the difference.',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.white.withOpacity(0.9))),
        const SizedBox(height: UIConstants.spacingLg),
        FilledButton.icon(
          onPressed: () => context.push(RouteNames.products),
          icon: const Icon(Icons.shopping_bag_outlined),
          label: const Text('Shop Now'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
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
              Text('Freshly Baked, Just for You', style: theme.textTheme.displaySmall?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: UIConstants.spacingMd),
              Text('Handcrafted with love using the finest ingredients.\nOrder today and taste the difference.',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.white.withOpacity(0.9))),
              const SizedBox(height: UIConstants.spacingLg),
              FilledButton.icon(
                onPressed: () => context.push(RouteNames.products),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Shop Now'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
            ],
          ),
        ),
        const SizedBox(width: UIConstants.spacingXl),
        Container(width: 200, height: 200, decoration: BoxDecoration(color: AppColors.white.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.cake, size: 100, color: AppColors.white)),
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
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding, vertical: UIConstants.spacingMd),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ]),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  const _CategoryChips({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.bakery_dining, size: 18),
              label: Text(cat.name),
              onPressed: () => context.push('${RouteNames.categories}/${cat.slug}'),
            ),
          );
        },
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  const _PromotionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UIConstants.pagePadding),
      padding: const EdgeInsets.all(UIConstants.spacingLg),
      decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(UIConstants.borderRadius), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(UIConstants.spacingMd), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm)),
            child: const Icon(Icons.local_offer_outlined, color: AppColors.secondary, size: 32)),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Weekend Special', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Get 15% off all cakes this weekend. Use code SWEET15 at checkout.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium)),
            ]),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
