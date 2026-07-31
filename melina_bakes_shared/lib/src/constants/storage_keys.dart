/// Keys used for local storage across the application.
abstract final class StorageKeys {
  StorageKeys._();

  /// JWT access token.
  static const String accessToken = 'mb_access_token';

  /// JWT refresh token.
  static const String refreshToken = 'mb_refresh_token';

  /// Token expiry timestamp.
  static const String tokenExpiry = 'mb_token_expiry';

  /// Remember me flag.
  static const String rememberMe = 'mb_remember_me';

  /// Current user data (JSON string).
  static const String userData = 'mb_user_data';

  /// Cart data (JSON string).
  static const String cartData = 'mb_cart_data';

  /// App theme mode (light/dark/system).
  static const String themeMode = 'mb_theme_mode';

  /// App locale.
  static const String locale = 'mb_locale';

  /// Onboarding completion flag.
  static const String onboardingComplete = 'mb_onboarding_complete';

  /// Last notification read timestamp.
  static const String lastNotificationRead = 'mb_last_notification_read';

  /// Push notification token.
  static const String pushToken = 'mb_push_token';
}
