
/// Shell screen providing persistent navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/widgets/cart_badge.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget child;
  final bool isAdmin;

  const ShellScreen({super.key, required this.child, this.isAdmin = false});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _getSelectedIndex(String location) {
    if (widget.isAdmin) return _adminRoutes.indexWhere((r) => location.startsWith(r.path));
    return _customerRoutes.indexWhere((r) => location == r.path);
  }

  void _onDestinationSelected(int index) {
    final routes = widget.isAdmin ? _adminRoutes : _customerRoutes;
    if (index >= 0 && index < routes.length) context.go(routes[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);
    final user = ref.watch(currentUserProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= UIConstants.tabletBreakpoint;
        if (isDesktop) {
          return Scaffold(
            body: Row(children: [
              NavigationRail(
                selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: _buildRailDestinations(),
                trailing: _buildUserMenu(context, user),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: widget.child),
            ]),
          );
        }
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
            onDestinationSelected: _onDestinationSelected,
            destinations: _buildNavDestinations(),
          ),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildRailDestinations() {
    final routes = widget.isAdmin ? _adminRoutes : _customerRoutes;
    return routes.map((r) {
      final icon = r.path == RouteNames.cart
          ? const CartBadge(child: Icon(Icons.shopping_cart_outlined))
          : Icon(r.icon);
      final selectedIcon = r.path == RouteNames.cart
          ? const CartBadge(child: Icon(Icons.shopping_cart))
          : Icon(r.selectedIcon);
      return NavigationRailDestination(
        icon: icon, selectedIcon: selectedIcon, label: Text(r.label),
      );
    }).toList();
  }

  List<NavigationDestination> _buildNavDestinations() {
    final routes = widget.isAdmin ? _adminRoutes : _customerRoutes;
    return routes.map((r) {
      if (r.path == RouteNames.cart) {
        return NavigationDestination(
          icon: const CartBadge(child: Icon(Icons.shopping_cart_outlined)),
          selectedIcon: const CartBadge(child: Icon(Icons.shopping_cart)),
          label: r.label,
        );
      }
      return NavigationDestination(
        icon: Icon(r.icon), selectedIcon: Icon(r.selectedIcon), label: r.label,
      );
    }).toList();
  }

  Widget _buildUserMenu(BuildContext context, UserEntity? user) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMd),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (user != null) ...[
          const Divider(),
          ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.primary,
              child: Text(user.initials, style: const TextStyle(color: AppColors.white))),
            title: Text(user.displayName, style: Theme.of(context).textTheme.labelMedium, overflow: TextOverflow.ellipsis),
            subtitle: Text(user.role.displayName, style: Theme.of(context).textTheme.labelSmall),
            onTap: () => context.go(RouteNames.profile),
          ),
        ],
        ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: const Text('Logout'),
          onTap: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ]),
    );
  }
}

class _NavRoute {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavRoute({required this.path, required this.label, required this.icon, required this.selectedIcon});
}

const List<_NavRoute> _customerRoutes = [
  _NavRoute(path: RouteNames.home, label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  _NavRoute(path: RouteNames.products, label: 'Shop', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront),
  _NavRoute(path: '/search', label: 'Search', icon: Icons.search_outlined, selectedIcon: Icons.search),
  _NavRoute(path: RouteNames.cart, label: 'Cart', icon: Icons.shopping_cart_outlined, selectedIcon: Icons.shopping_cart),
  _NavRoute(path: RouteNames.orders, label: 'Orders', icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long),
  _NavRoute(path: RouteNames.profile, label: 'Profile', icon: Icons.person_outline, selectedIcon: Icons.person),
];

const List<_NavRoute> _adminRoutes = [
  _NavRoute(path: RouteNames.adminDashboard, label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard),
  _NavRoute(path: RouteNames.adminOrders, label: 'Orders', icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long),
  _NavRoute(path: RouteNames.adminProducts, label: 'Products', icon: Icons.cake_outlined, selectedIcon: Icons.cake),
  _NavRoute(path: RouteNames.adminCustomers, label: 'Customers', icon: Icons.people_outline, selectedIcon: Icons.people),
  _NavRoute(path: RouteNames.adminInventory, label: 'Inventory', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2),
  _NavRoute(path: RouteNames.adminReports, label: 'Reports', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart),
  _NavRoute(path: RouteNames.adminStaff, label: 'Staff', icon: Icons.badge_outlined, selectedIcon: Icons.badge),
  _NavRoute(path: RouteNames.adminCoupons, label: 'Coupons', icon: Icons.confirmation_number_outlined, selectedIcon: Icons.confirmation_number),
];
