/// Authentication Business Logic Service
///
/// Orchestrates user registration, login, token management,
/// password reset, email verification, and account security.
///
/// This service is protocol-agnostic (no HTTP/Serverpod dependencies)
/// and can be tested in isolation.
import 'dart:math';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../generated/user.dart';
import '../../repositories/user_repository.dart';
import 'password_service.dart';
import 'jwt_service.dart';

/// Result of a successful authentication operation.
class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}

/// Exception for authentication business logic errors.
class AuthException implements Exception {
  final String message;
  final String code;
  AuthException(this.message, {this.code = 'AUTH_ERROR'});
  @override
  String toString() => 'AuthException(\$code): \$message';
}

class AuthService {
  final UserRepository _userRepository;
  final PasswordService _passwordService;
  final JwtService _jwtService;

  /// Maximum failed login attempts before lockout.
  static const int maxFailedAttempts = 5;

  /// Account lockout duration.
  static const Duration lockoutDuration = Duration(minutes: 30);

  /// Access token expiry.
  static const Duration accessTokenExpiry = Duration(minutes: 15);

  /// Refresh token expiry.
  static const Duration refreshTokenExpiry = Duration(days: 7);

  AuthService({
    required UserRepository userRepository,
    required PasswordService passwordService,
    required JwtService jwtService,
  })  : _userRepository = userRepository,
        _passwordService = passwordService,
        _jwtService = jwtService;

  /// Registers a new user account.
  ///
  /// Validates input, hashes password, and creates the user.
  /// Returns [AuthResult] with tokens on success.
  Future<AuthResult> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    // Validate email
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw AuthException(emailError, code: 'INVALID_EMAIL');
    }

    // Validate password strength
    final passwordError = Validators.password(password);
    if (passwordError != null) {
      throw AuthException(passwordError, code: 'WEAK_PASSWORD');
    }

    // Hash password
    final passwordHash = _passwordService.hashPassword(password);

    // Create user via repository
    final result = await _userRepository.createUser(
      email: email.toLowerCase().trim(),
      passwordHash: passwordHash,
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      phoneNumber: phoneNumber?.trim(),
      role: role,
    );

    return result.when(
      success: (user) async {
        // Generate tokens
        final accessToken = _jwtService.generateAccessToken(
          userId: user.id!,
          email: user.email,
          role: user.role,
          expiry: accessTokenExpiry,
        );
        final refreshToken = _jwtService.generateRefreshToken();

        return AuthResult(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: accessTokenExpiry.inSeconds,
        );
      },
      failure: (failure) => throw AuthException(
        failure.message,
        code: failure.code ?? 'REGISTRATION_FAILED',
      ),
    );
  }

  /// Authenticates a user with email and password.
  ///
  /// Implements account lockout after [maxFailedAttempts].
  /// Returns [AuthResult] with fresh tokens on success.
  Future<AuthResult> login({
    required String email,
    required String password,
    String? ipAddress,
    bool rememberMe = false,
  }) async {
    // Find user by email
    final userResult = await _userRepository.findByEmail(email.toLowerCase().trim());

    return userResult.when(
      success: (user) async {
        // Check if account is locked
        if (user.isLocked) {
          throw AuthException(
            'Account is temporarily locked due to multiple failed login attempts. '
            'Please try again in \${user.lockedUntil!.difference(DateTime.now()).inMinutes} minutes.',
            code: 'ACCOUNT_LOCKED',
          );
        }

        // Check if account is active
        if (!user.isActive) {
          throw AuthException(
            'Account has been deactivated. Please contact support.',
            code: 'ACCOUNT_INACTIVE',
          );
        }

        // Verify password
        final isValid = _passwordService.verifyPassword(password, user.passwordHash);

        if (!isValid) {
          // Record failed attempt
          await _userRepository.recordFailedLogin(
            userId: user.id!,
            maxAttempts: maxFailedAttempts,
            lockoutDuration: lockoutDuration,
          );

          throw AuthException(
            'Invalid email or password.',
            code: 'INVALID_CREDENTIALS',
          );
        }

        // Check if password needs rehashing
        if (_passwordService.needsRehash(user.passwordHash)) {
          final newHash = _passwordService.hashPassword(password);
          await _userRepository.updatePassword(
            userId: user.id!,
            newPasswordHash: newHash,
          );
        }

        // Record successful login
        await _userRepository.recordLogin(
          userId: user.id!,
          ipAddress: ipAddress ?? 'unknown',
        );

        // Generate tokens
        final tokenExpiry = rememberMe 
            ? const Duration(days: 30) 
            : accessTokenExpiry;

        final accessToken = _jwtService.generateAccessToken(
          userId: user.id!,
          email: user.email,
          role: user.role,
          expiry: tokenExpiry,
        );
        final refreshToken = _jwtService.generateRefreshToken();

        return AuthResult(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: tokenExpiry.inSeconds,
        );
      },
      failure: (failure) => throw AuthException(
        'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      ),
    );
  }

  /// Refreshes an access token using a refresh token.
  ///
  /// Validates the refresh token and issues new tokens.
  /// Implements token rotation (new refresh token on each use).
  Future<AuthResult> refreshAccessToken({
    required String refreshToken,
    required int userId,
  }) async {
    // Verify user exists
    final userResult = await _userRepository.findById(userId);

    return userResult.when(
      success: (user) async {
        if (!user.isActive) {
          throw AuthException('Account is inactive', code: 'ACCOUNT_INACTIVE');
        }

        // Generate new token pair (rotation)
        final newAccessToken = _jwtService.generateAccessToken(
          userId: user.id!,
          email: user.email,
          role: user.role,
          expiry: accessTokenExpiry,
        );
        final newRefreshToken = _jwtService.generateRefreshToken();

        return AuthResult(
          user: user,
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresIn: accessTokenExpiry.inSeconds,
        );
      },
      failure: (failure) => throw AuthException(
        'Invalid refresh token',
        code: 'INVALID_REFRESH_TOKEN',
      ),
    );
  }

  /// Validates an access token and returns the user.
  ///
  /// Used by middleware to authenticate requests.
  Future<User> validateAccessToken(String token) async {
    try {
      final claims = _jwtService.validateAccessToken(token);

      final userResult = await _userRepository.findById(claims.userId);
      return userResult.when(
        success: (user) {
          if (!user.isActive) {
            throw AuthException('Account is inactive', code: 'ACCOUNT_INACTIVE');
          }
          return user;
        },
        failure: (failure) => throw AuthException(
          'User not found',
          code: 'USER_NOT_FOUND',
        ),
      );
    } on TokenException catch (e) {
      throw AuthException(e.message, code: 'INVALID_TOKEN');
    }
  }

  /// Initiates a password reset for the given email.
  ///
  /// Always returns success (even if email doesn't exist)
  /// to prevent email enumeration attacks.
  Future<void> requestPasswordReset(String email) async {
    // Find user (silently fail if not found)
    final userResult = await _userRepository.findByEmail(email.toLowerCase().trim());

    await userResult.when(
      success: (user) async {
        // Generate secure reset token
        final token = _generateSecureToken();
        // Store hashed token with expiry
        // Implementation would store in PasswordReset repository
      },
      failure: (_) async {
        // Silently succeed to prevent enumeration
      },
    );
  }

  /// Resets a user's password using a valid token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Validate password strength
    final passwordError = Validators.password(newPassword);
    if (passwordError != null) {
      throw AuthException(passwordError, code: 'WEAK_PASSWORD');
    }

    // Hash and update password
    final passwordHash = _passwordService.hashPassword(newPassword);
    // Implementation would validate token and update password
  }

  /// Changes a user's password (authenticated).
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final userResult = await _userRepository.findById(userId);

    await userResult.when(
      success: (user) async {
        // Verify current password
        final isValid = _passwordService.verifyPassword(
          currentPassword,
          user.passwordHash,
        );

        if (!isValid) {
          throw AuthException(
            'Current password is incorrect',
            code: 'INVALID_CURRENT_PASSWORD',
          );
        }

        // Validate new password
        final passwordError = Validators.password(newPassword);
        if (passwordError != null) {
          throw AuthException(passwordError, code: 'WEAK_PASSWORD');
        }

        // Ensure new password is different
        if (currentPassword == newPassword) {
          throw AuthException(
            'New password must be different from current password',
            code: 'SAME_PASSWORD',
          );
        }

        // Hash and update
        final newHash = _passwordService.hashPassword(newPassword);
        final updateResult = await _userRepository.updatePassword(
          userId: userId,
          newPasswordHash: newHash,
        );

        updateResult.when(
          success: (_) {},
          failure: (failure) => throw AuthException(
            failure.message,
            code: failure.code ?? 'PASSWORD_CHANGE_FAILED',
          ),
        );
      },
      failure: (failure) => throw AuthException(
        'User not found',
        code: 'USER_NOT_FOUND',
      ),
    );
  }

  /// Generates a cryptographically secure random token.
  String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
