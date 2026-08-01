
/// Bottom sheet for filtering and sorting products.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/product_providers.dart';

class ProductFilterSheet extends ConsumerStatefulWidget {
  const ProductFilterSheet({super.key});

  @override
  ConsumerState<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<ProductFilterSheet> {
  String? _selectedSort;
  double? _minPrice;
  double? _maxPrice;

  static const _sortOptions = [
    MapEntry('name', 'Name (A-Z)'),
    MapEntry('name_desc', 'Name (Z-A)'),
    MapEntry('price_asc', 'Price (Low to High)'),
    MapEntry('price_desc', 'Price (High to Low)'),
    MapEntry('popular', 'Most Popular'),
    MapEntry('newest', 'Newest First'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onLightLow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          Text('Sort By', style: theme.textTheme.titleLarge),
          const SizedBox(height: UIConstants.spacingMd),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sortOptions.map((option) {
              final isSelected = _selectedSort == option.key;
              return ChoiceChip(
                label: Text(option.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSort = selected ? option.key : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          Text('Price Range', style: theme.textTheme.titleLarge),
          const SizedBox(height: UIConstants.spacingMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    prefixText: '\$',
                  ),
                  onChanged: (v) => _minPrice = double.tryParse(v),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('—'),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    prefixText: '\$',
                  ),
                  onChanged: (v) => _maxPrice = double.tryParse(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingXl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(productListProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    String? sortBy;
                    bool sortDesc = false;
                    if (_selectedSort != null) {
                      if (_selectedSort == 'name_desc') {
                        sortBy = 'name';
                        sortDesc = true;
                      } else if (_selectedSort == 'price_asc') {
                        sortBy = 'price';
                      } else if (_selectedSort == 'price_desc') {
                        sortBy = 'price';
                        sortDesc = true;
                      } else {
                        sortBy = _selectedSort;
                      }
                    }
                    ref.read(productListProvider.notifier).updateFilter(
                      ProductFilter(
                        sortBy: sortBy,
                        sortDescending: sortDesc,
                        minPrice: _minPrice,
                        maxPrice: _maxPrice,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMd),
        ],
      ),
    );
  }
}
