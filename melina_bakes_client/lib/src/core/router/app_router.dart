
/// GoRouter configuration with auth guards and role-based access.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/shell_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/category_list_screen.dart';
import '../../features/products/presentation/screens/category_detail_screen.dart';
import '../../features/products/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_customers_screen.dart';
import '../../features/admin/presentation/screens/admin_inventory_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_staff_screen.dart';
import '../../features/admin/presentation/screens/admin_coupons_screen.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    redirect: (context, state) => _handleRedirect(ref, authState, state),
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),

      ShellRoute(
        builder: (_, __, child) => ShellScreen(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: RouteNames.products, builder: (_, __) => const ProductListScreen()),
          GoRoute(path: RouteNames.productDetail, builder: (context, state) => ProductDetailScreen(slug: state.pathParameters['slug']!)),
          GoRoute(path: RouteNames.categories, builder: (_, __) => const CategoryListScreen()),
          GoRoute(path: RouteNames.categoryDetail, builder: (context, state) => CategoryDetailScreen(slug: state.pathParameters['slug']!)),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: RouteNames.cart, builder: (_, __) => const CartScreen()),
          GoRoute(
            path: RouteNames.checkout,
            builder: (_, __) => const CheckoutScreen(),
            redirect: (_, s) => _requireAuth(ref, s),
          ),
          GoRoute(
            path: RouteNames.orderSuccess,
            builder: (_, __) => const OrderSuccessScreen(),
            redirect: (_, s) => _requireAuth(ref, s),
          ),
          GoRoute(
            path: RouteNames.orders,
            builder: (_, __) => const OrdersScreen(),
            redirect: (_, s) => _requireAuth(ref, s),
            routes: [
              GoRoute(
                path: ':number',
                builder: (_, state) => OrderDetailScreen(
                  orderNumber: state.pathParameters['number']!,
                ),
                routes: [
                  GoRoute(
                    path: 'track',
                    builder: (_, state) => OrderTrackingScreen(
                      orderNumber: state.pathParameters['number']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const Placeholder(key: ValueKey('profile')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.wishlist, builder: (_, __) => const Placeholder(key: ValueKey('wishlist')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.notifications, builder: (_, __) => const Placeholder(key: ValueKey('notifications')), redirect: (_, s) => _requireAuth(ref, s)),
        ],
      ),

      GoRoute(path: RouteNames.admin, redirect: (_, __) => RouteNames.adminDashboard),
      ShellRoute(
        builder: (_, __, child) => ShellScreen(child: child, isAdmin: true),
        routes: [
          GoRoute(path: RouteNames.adminDashboard, builder: (_, __) => const AdminDashboardScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminOrders, builder: (_, __) => const AdminOrdersScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminProducts, builder: (_, __) => const AdminProductsScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminCategories, builder: (_, __) => const Placeholder(key: ValueKey('admin-categories')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminCustomers, builder: (_, __) => const AdminCustomersScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminInventory, builder: (_, __) => const AdminInventoryScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminReports, builder: (_, __) => const AdminReportsScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminStaff, builder: (_, __) => const AdminStaffScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.admin)),
          GoRoute(path: RouteNames.adminCoupons, builder: (_, __) => const AdminCouponsScreen(), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminSettings, builder: (_, __) => const Placeholder(key: ValueKey('admin-settings')), redirect: (_, s) => _requireRole(ref, s, UserRole.admin)),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(body: Center(child: Text('Route not found: ${state.uri.path}'))),
  );
});

String? _handleRedirect(ProviderRef<GoRouter> ref, AuthState auth, GoRouterState state) {
  final isAuth = auth is AuthenticatedAuthState;
  final isAuthRoute = state.matchedLocation == RouteNames.login || state.matchedLocation == RouteNames.register;
  if (!isAuth && !isAuthRoute && state.matchedLocation.startsWith('/admin')) return RouteNames.login;
  if (isAuth && isAuthRoute) {
    final user = (auth as AuthenticatedAuthState).user;
    if (user.role.hasPermission(UserRole.manager)) return RouteNames.adminDashboard;
    return RouteNames.home;
  }
  return null;
}

String? _requireAuth(ProviderRef<GoRouter> ref, GoRouterState state) {
  final auth = ref.read(authControllerProvider);
  if (auth is! AuthenticatedAuthState) return RouteNames.login;
  return null;
}

String? _requireRole(ProviderRef<GoRouter> ref, GoRouterState state, UserRole minRole) {
  final auth = ref.read(authControllerProvider);
  if (auth is! AuthenticatedAuthState) return RouteNames.login;
  if (!auth.user.role.hasPermission(minRole)) return RouteNames.home;
  return null;
}
