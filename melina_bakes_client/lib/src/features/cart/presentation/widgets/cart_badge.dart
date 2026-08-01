
/// Cart item count badge for the navigation icon.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';

class CartBadge extends ConsumerWidget {
  final Widget child;

  const CartBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);

    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      child: child,
    );
  }
}
