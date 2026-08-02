/// Order success / confirmation screen displayed after a customer
/// successfully places an order.
///
/// Shows the order number, estimated delivery date, and actions to
/// either track the order or return to shopping.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/order_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mutation = ref.watch(orderMutationProvider);
    final order = mutation is OrderMutationCreated ? mutation.order : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 52,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),

                Text(
                  'Order Confirmed!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: UIConstants.spacingSm),

                if (order != null) ...[
                  Text(
                    'Your order #${order.orderNumber} has been placed.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onLightMedium,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  if (order.estimatedDeliveryDate != null)
                    Text(
                      'Estimated delivery: ${_formatDate(order.estimatedDeliveryDate!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                ],

                const SizedBox(height: UIConstants.spacingXl),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (order != null) {
                        context.go('${RouteNames.orders}/${order.orderNumber}');
                      }
                    },
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('View Order'),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go(RouteNames.products),
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}