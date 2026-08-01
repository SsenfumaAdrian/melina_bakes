
/// Animated add-to-cart button with quantity controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';

class AddToCartButton extends ConsumerStatefulWidget {
  final int productId;
  final double price;
  final bool inStock;

  const AddToCartButton({
    super.key,
    required this.productId,
    required this.price,
    required this.inStock,
  });

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _justAdded = false;

  void _addToCart() {
    if (!widget.inStock) return;
    ref.read(cartControllerProvider.notifier).addItem(
      productId: widget.productId,
      quantity: 1,
    );
    setState(() => _justAdded = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_justAdded) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check),
        label: const Text('Added!'),
        style: FilledButton.styleFrom(backgroundColor: AppColors.success),
      ).animate().scale(duration: 200.ms);
    }

    return FilledButton.icon(
      onPressed: widget.inStock ? _addToCart : null,
      icon: const Icon(Icons.add_shopping_cart),
      label: Text(widget.inStock ? 'Add to Cart' : 'Out of Stock'),
    );
  }
}
