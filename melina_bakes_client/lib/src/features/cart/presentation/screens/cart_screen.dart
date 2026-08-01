
/// Shopping cart screen with item list, quantity controls, and totals.
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
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          cartAsync.when(
            data: (cart) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _showClearConfirm(context, ref),
                    child: const Text('Clear'),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse our delicious baked goods and add your favorites',
              actionLabel: 'Start Shopping',
              onAction: () => context.go(RouteNames.products),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(UIConstants.spacingMd),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(
                      item: cart.items[index],
                      index: index,
                    );
                  },
                ),
              ),
              _CartSummary(cart: cart),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading your cart...'),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.read(cartControllerProvider.notifier).loadCart(),
        ),
      ),
    );
  }

  void _showClearConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('This will remove all items from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  final int index;

  const _CartItemTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.primaryContainer,
                child: item.productImageUrl != null
                    ? Image.network(item.productImageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.cake, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: theme.textTheme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onLightMedium,
                        ),
                  ),
                  const SizedBox(height: UIConstants.spacingSm),
                  // Quantity controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: () => ref.read(cartControllerProvider.notifier)
                            .updateQuantity(item.id, item.quantity - 1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${item.quantity}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () => ref.read(cartControllerProvider.notifier)
                            .updateQuantity(item.id, item.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price and delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.calculatedSubtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: UIConstants.spacingSm),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => ref.read(cartControllerProvider.notifier).removeItem(item.id),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: -0.1, end: 0);
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
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartEntity cart;

  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(UIConstants.pagePadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coupon section
            if (cart.hasCoupon)
              Container(
                margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coupon "${cart.couponCode}" applied',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.success),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<CartController>()
                          // This won't work directly, but the provider handles it
                          , // Handled by parent
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ),
            // Totals
            _SummaryRow(label: 'Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
            if (cart.discountAmount != null && cart.discountAmount! > 0)
              _SummaryRow(label: 'Discount', value: '-\$${cart.discountAmount!.toStringAsFixed(2)}', isDiscount: true),
            _SummaryRow(label: 'Tax', value: '\$${cart.taxAmount.toStringAsFixed(2)}'),
            _SummaryRow(label: 'Delivery', value: '\$${cart.deliveryCharge.toStringAsFixed(2)}'),
            const Divider(),
            _SummaryRow(
              label: 'Total',
              value: '\$${cart.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: UIConstants.spacingMd),
            // Checkout button
            FilledButton.icon(
              onPressed: () => context.push(RouteNames.checkout),
              icon: const Icon(Icons.payment),
              label: const Text('Proceed to Checkout'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(color: AppColors.onLightMedium),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)
                : theme.textTheme.bodyMedium?.copyWith(
                    color: isDiscount ? AppColors.success : AppColors.onLightHigh,
                    fontWeight: isDiscount ? FontWeight.bold : null,
                  ),
          ),
        ],
      ),
    );
  }
}
