
/// Application-wide constants for the Melina Bakes client.
///
/// Contains API endpoints, timeouts, UI constants, and
/// storage keys used across the application.
library;

/// API and network configuration.
abstract final class ApiConfig {
  ApiConfig._();

  /// Base URL for the Melina Bakes API.
  ///
  /// Override via environment or build configuration.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Connection timeout for API requests.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Receive timeout for API responses.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout for file uploads.
  static const Duration sendTimeout = Duration(seconds: 60);

  /// Maximum number of retry attempts for failed requests.
  static const int maxRetries = 3;

/// Retry delay between failed attempts.
static const Duration retryDelay = Duration(seconds: 1);
}
abstract final class UIConstants {
  UIConstants._();

  /// Default page padding.
  static const double pagePadding = 24.0;

  /// Small spacing unit.
  static const double spacingXs = 4.0;

  /// Small spacing unit.
  static const double spacingSm = 8.0;

  /// Medium spacing unit.
  static const double spacingMd = 16.0;

  /// Large spacing unit.
  static const double spacingLg = 24.0;

  /// Extra large spacing unit.
  static const double spacingXl = 32.0;

  /// Default border radius for cards and containers.
  static const double borderRadius = 16.0;

  /// Small border radius for buttons and chips.
  static const double borderRadiusSm = 8.0;

  /// Large border radius for modals and dialogs.
  static const double borderRadiusLg = 24.0;

  /// Default animation duration.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Stagger animation delay for lists.
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Maximum content width for desktop layouts.
  static const double maxContentWidth = 1440.0;

  /// Breakpoint for mobile layouts.
  static const double mobileBreakpoint = 600.0;

  /// Breakpoint for tablet layouts.
  static const double tabletBreakpoint = 1024.0;

  /// Breakpoint for desktop layouts.
  static const double desktopBreakpoint = 1440.0;
}

/// Pagination defaults.
abstract final class PaginationDefaults {
  PaginationDefaults._();

  /// Default page number (1-based).
  static const int page = 1;

  /// Default items per page.
  static const int pageSize = 20;

  /// Maximum items per page allowed.
  static const int maxPageSize = 100;
}
