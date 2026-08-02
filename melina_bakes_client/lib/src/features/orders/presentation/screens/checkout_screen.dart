/// Checkout screen that collects the delivery address, delivery method,
/// customer notes, and triggers order creation from the current cart.
///
/// After a successful placement the user is redirected to the order
/// success screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../cart/cart.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalController = TextEditingController();
  final _notesController = TextEditingController();

  String _deliveryMethod = 'standard';

  /// Delivery method options as const records (value, label).
  static const List<({String value, String label})> _deliveryMethods = [
    (value: 'standard', label: 'Standard Delivery (1-3 days)'),
    (value: 'express', label: 'Express Delivery (Same day)'),
    (value: 'pickup', label: 'Store Pickup'),
  ];

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final mutation = ref.watch(orderMutationProvider);
    final theme = Theme.of(context);

    // Redirect to success screen after order creation.
    ref.listen<OrderMutationState>(orderMutationProvider, (previous, next) {
      if (next is OrderMutationCreated) {
        context.go(RouteNames.orderSuccess);
      }
    });

    return cartAsync.when(
      loading: () => const LoadingIndicator(message: 'Loading cart...'),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(child: Text(err.toString())),
      ),
      data: (cart) {
        if (cart.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go(RouteNames.products),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Checkout')),
          bottomNavigationBar: _CheckoutBottomBar(
            cart: cart,
            mutation: mutation,
            onPlaceOrder: () => _placeOrder(),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(UIConstants.pagePadding),
              children: [
                // Delivery address section
                Text('Delivery Address', style: theme.textTheme.titleMedium),
                const SizedBox(height: UIConstants.spacingMd),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Street address is required' : null,
                ),
                const SizedBox(height: UIConstants.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'City is required' : null,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingMd),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingMd),
                TextFormField(
                  controller: _postalController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),

                // Delivery method
                Text('Delivery Method', style: theme.textTheme.titleMedium),
                const SizedBox(height: UIConstants.spacingSm),
                ..._deliveryMethods.map((method) => RadioListTile<String>(
                      value: method.value,
                      groupValue: _deliveryMethod,
                      onChanged: (value) =>
                          setState(() => _deliveryMethod = value ?? 'standard'),
                      title: Text(method.label),
                      dense: true,
                    )),
                const SizedBox(height: UIConstants.spacingMd),

                // Additional notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Order Notes (optional)',
                    hintText: 'E.g. "Please call before delivery"',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                // Error banner
                if (mutation is OrderMutationFailure)
                  Padding(
                    padding: const EdgeInsets.only(top: UIConstants.spacingMd),
                    child: Container(
                      padding: const EdgeInsets.all(UIConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSm),
                      ),
                      child: Text(
                        mutation.message,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    final notes = _notesController.text.trim();
    ref.read(orderMutationProvider.notifier).createOrder(
          // The full address book integration is part of the customer
          // dashboard phase; for now we send a stable placeholder id.
          deliveryAddressId: 1,
          deliveryMethod: _deliveryMethod,
          customerNotes: notes.isNotEmpty ? notes : null,
        );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final CartEntity cart;
  final OrderMutationState mutation;
  final VoidCallback onPlaceOrder;

  const _CheckoutBottomBar({
    required this.cart,
    required this.mutation,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = mutation is OrderMutationLoading;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingMd),
        child: Row(
          children: [
            Text(
              '\$${cart.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: isLoading ? null : onPlaceOrder,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.payment),
              label: Text(isLoading ? 'Placing Order...' : 'Place Order'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}