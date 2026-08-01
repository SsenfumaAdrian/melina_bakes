
/// Search screen with suggestions, recent searches, and results.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    ref.read(productListProvider.notifier).updateFilter(
      ProductFilter(searchQuery: query.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider(query));
    final productsAsync = ref.watch(productListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search cakes, pastries, bread...',
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      setState(() => _hasSearched = false);
                    },
                  )
                : null,
          ),
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          onSubmitted: _performSearch,
        ),
      ),
      body: _hasSearched
          ? productsAsync.when(
              data: (paginated) {
                if (paginated.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No results for "${_controller.text}"',
                    subtitle: 'Try different keywords or browse categories',
                    actionLabel: 'Browse All',
                    onAction: () => context.go(RouteNames.products),
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
              loading: () => const LoadingIndicator(message: 'Searching...'),
              error: (err, _) => Center(child: Text('Error: $err')),
            )
          : _buildSuggestions(suggestionsAsync, theme),
    );
  }

  Widget _buildSuggestions(AsyncValue<List<String>> suggestionsAsync, ThemeData theme) {
    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty && _controller.text.length < 2) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 64, color: AppColors.onLightLow),
                const SizedBox(height: 16),
                Text('Start typing to search', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Find cakes, pastries, bread, and more', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onLightMedium)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.search),
            title: Text(suggestions[index]),
            onTap: () {
              _controller.text = suggestions[index];
              _performSearch(suggestions[index]);
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
