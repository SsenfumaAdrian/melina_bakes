
/// Centralized route path definitions.
library;

abstract final class RouteNames {
  RouteNames._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:slug';
  static const String categories = '/categories';
  static const String categoryDetail = '/categories/:slug';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:number';
  static const String trackOrder = '/track-order';
  static const String profile = '/profile';
  static const String addresses = '/addresses';
  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';

  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminCustomers = '/admin/customers';
  static const String adminInventory = '/admin/inventory';
  static const String adminReports = '/admin/reports';
  static const String adminStaff = '/admin/staff';
  static const String adminCoupons = '/admin/coupons';
  static const String adminSettings = '/admin/settings';

  static const String about = '/about';
  static const String contact = '/contact';
  static const String faq = '/faq';
  static const String gallery = '/gallery';
}
