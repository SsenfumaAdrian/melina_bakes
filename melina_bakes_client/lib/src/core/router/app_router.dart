
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
          GoRoute(path: RouteNames.products, builder: (_, __) => const Placeholder(key: ValueKey('products'))),
          GoRoute(path: RouteNames.productDetail, builder: (_, __) => const Placeholder(key: ValueKey('product-detail'))),
          GoRoute(path: RouteNames.categories, builder: (_, __) => const Placeholder(key: ValueKey('categories'))),
          GoRoute(path: RouteNames.cart, builder: (_, __) => const Placeholder(key: ValueKey('cart'))),
          GoRoute(path: RouteNames.checkout, builder: (_, __) => const Placeholder(key: ValueKey('checkout')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.orders, builder: (_, __) => const Placeholder(key: ValueKey('orders')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.orderDetail, builder: (_, __) => const Placeholder(key: ValueKey('order-detail')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const Placeholder(key: ValueKey('profile')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.wishlist, builder: (_, __) => const Placeholder(key: ValueKey('wishlist')), redirect: (_, s) => _requireAuth(ref, s)),
          GoRoute(path: RouteNames.notifications, builder: (_, __) => const Placeholder(key: ValueKey('notifications')), redirect: (_, s) => _requireAuth(ref, s)),
        ],
      ),

      GoRoute(path: RouteNames.admin, redirect: (_, __) => RouteNames.adminDashboard),
      ShellRoute(
        builder: (_, __, child) => ShellScreen(child: child, isAdmin: true),
        routes: [
          GoRoute(path: RouteNames.adminDashboard, builder: (_, __) => const Placeholder(key: ValueKey('admin-dashboard')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminOrders, builder: (_, __) => const Placeholder(key: ValueKey('admin-orders')), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminProducts, builder: (_, __) => const Placeholder(key: ValueKey('admin-products')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminCategories, builder: (_, __) => const Placeholder(key: ValueKey('admin-categories')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminCustomers, builder: (_, __) => const Placeholder(key: ValueKey('admin-customers')), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminInventory, builder: (_, __) => const Placeholder(key: ValueKey('admin-inventory')), redirect: (_, s) => _requireRole(ref, s, UserRole.staff)),
          GoRoute(path: RouteNames.adminReports, builder: (_, __) => const Placeholder(key: ValueKey('admin-reports')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
          GoRoute(path: RouteNames.adminStaff, builder: (_, __) => const Placeholder(key: ValueKey('admin-staff')), redirect: (_, s) => _requireRole(ref, s, UserRole.admin)),
          GoRoute(path: RouteNames.adminCoupons, builder: (_, __) => const Placeholder(key: ValueKey('admin-coupons')), redirect: (_, s) => _requireRole(ref, s, UserRole.manager)),
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

  if (!isAuth && !isAuthRoute && state.matchedLocation.startsWith('/admin')) {
    return RouteNames.login;
  }
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
