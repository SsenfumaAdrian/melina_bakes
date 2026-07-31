/// API endpoint constants shared between client and server.
abstract final class ApiConstants {
  ApiConstants._();

  /// Base API path.
  static const String apiBase = '/api';

  /// API version.
  static const String apiVersion = 'v1';

  /// Full API base path.
  static const String apiV1Base = '\$apiBase/\$apiVersion';

  // Auth endpoints
  static const String authRegister = '\$apiV1Base/auth/register';
  static const String authLogin = '\$apiV1Base/auth/login';
  static const String authLogout = '\$apiV1Base/auth/logout';
  static const String authRefresh = '\$apiV1Base/auth/refresh';
  static const String authForgotPassword = '\$apiV1Base/auth/forgot-password';
  static const String authResetPassword = '\$apiV1Base/auth/reset-password';
  static const String authVerifyEmail = '\$apiV1Base/auth/verify-email';
  static const String authResendVerification = '\$apiV1Base/auth/resend-verification';
  static const String authMe = '\$apiV1Base/auth/me';
  static const String authUpdateProfile = '\$apiV1Base/auth/profile';
  static const String authChangePassword = '\$apiV1Base/auth/change-password';

  // Product endpoints
  static const String products = '\$apiV1Base/products';
  static const String categories = '\$apiV1Base/categories';
  static const String featuredProducts = '\$apiV1Base/products/featured';

  // Cart endpoints
  static const String cart = '\$apiV1Base/cart';
  static const String cartItems = '\$apiV1Base/cart/items';
  static const String cartApplyCoupon = '\$apiV1Base/cart/apply-coupon';
  static const String cartRemoveCoupon = '\$apiV1Base/cart/remove-coupon';

  // Order endpoints
  static const String orders = '\$apiV1Base/orders';
  static const String orderCreate = '\$apiV1Base/orders';
  static const String orderTrack = '\$apiV1Base/orders/track';

  // Payment endpoints
  static const String payments = '\$apiV1Base/payments';
  static const String paymentIntent = '\$apiV1Base/payments/intent';
  static const String paymentConfirm = '\$apiV1Base/payments/confirm';
  static const String paymentWebhook = '\$apiV1Base/payments/webhook';

  // Customer endpoints
  static const String customerProfile = '\$apiV1Base/customer/profile';
  static const String customerAddresses = '\$apiV1Base/customer/addresses';
  static const String customerOrders = '\$apiV1Base/customer/orders';
  static const String customerWishlist = '\$apiV1Base/customer/wishlist';
  static const String customerNotifications = '\$apiV1Base/customer/notifications';

  // Admin endpoints
  static const String adminDashboard = '\$apiV1Base/admin/dashboard';
  static const String adminOrders = '\$apiV1Base/admin/orders';
  static const String adminCustomers = '\$apiV1Base/admin/customers';
  static const String adminProducts = '\$apiV1Base/admin/products';
  static const String adminCategories = '\$apiV1Base/admin/categories';
  static const String adminInventory = '\$apiV1Base/admin/inventory';
  static const String adminCoupons = '\$apiV1Base/admin/coupons';
  static const String adminReports = '\$apiV1Base/admin/reports';
  static const String adminStaff = '\$apiV1Base/admin/staff';

  // CMS endpoints
  static const String cmsBanners = '\$apiV1Base/cms/banners';
  static const String cmsPromotions = '\$apiV1Base/cms/promotions';
  static const String cmsTestimonials = '\$apiV1Base/cms/testimonials';
  static const String cmsFaqs = '\$apiV1Base/cms/faqs';

  // Upload endpoints
  static const String uploadImage = '\$apiV1Base/upload/image';
  static const String uploadBulk = '\$apiV1Base/upload/bulk';

  // WebSocket endpoint
  static const String webSocket = '/ws';
}
