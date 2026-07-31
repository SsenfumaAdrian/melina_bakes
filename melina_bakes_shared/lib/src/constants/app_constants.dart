/// Application-wide constants for Melina Bakes.
/// 
/// These values are shared between client and server.
abstract final class AppConstants {
  AppConstants._();

  /// Application name.
  static const String appName = 'Melina Bakes';

  /// Application version.
  static const String appVersion = '1.0.0';

  /// Application build number.
  static const String buildNumber = '1';

  /// Default currency symbol.
  static const String defaultCurrency = '\$';

  /// Default currency code (ISO 4217).
  static const String defaultCurrencyCode = 'USD';

  /// Default locale.
  static const String defaultLocale = 'en_US';

  /// Default timezone.
  static const String defaultTimezone = 'UTC';

  /// Pagination default page size.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed.
  static const int maxPageSize = 100;

  /// Maximum upload file size in bytes (10MB).
  static const int maxUploadSize = 10 * 1024 * 1024;

  /// Supported image extensions.
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// JWT access token expiry duration.
  static const Duration accessTokenExpiry = Duration(minutes: 15);

  /// JWT refresh token expiry duration.
  static const Duration refreshTokenExpiry = Duration(days: 7);

  /// Remember me token expiry duration (30 days).
  static const Duration rememberMeExpiry = Duration(days: 30);

  /// Session timeout for inactive users.
  static const Duration sessionTimeout = Duration(hours: 2);

  /// Rate limit: max requests per minute for general API.
  static const int rateLimitGeneral = 100;

  /// Rate limit: max requests per minute for auth endpoints.
  static const int rateLimitAuth = 10;

  /// Low stock threshold (quantity).
  static const int lowStockThreshold = 10;

  /// Critical stock threshold (quantity).
  static const int criticalStockThreshold = 3;

  /// Default tax rate (percentage).
  static const double defaultTaxRate = 8.0;

  /// Free delivery threshold amount.
  static const double freeDeliveryThreshold = 50.0;

  /// Standard delivery charge.
  static const double standardDeliveryCharge = 5.99;
}
