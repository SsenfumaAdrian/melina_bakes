
/// Repository contract for authentication operations.
///
/// Defines the boundary between the domain and data layers
/// for all auth-related business logic.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  /// Registers a new customer account.
  ///
  /// Returns the authenticated [UserEntity] with tokens on success.
  Future<Result<UserEntity, Failure>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });

  /// Authenticates an existing user.
  ///
  /// Returns the authenticated [UserEntity] with tokens on success.
  Future<Result<UserEntity, Failure>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Refreshes the access token using a refresh token.
  Future<Result<UserEntity, Failure>> refreshToken();

  /// Logs out the current user and clears stored credentials.
  Future<Result<void, Failure>> logout();

  /// Sends a password reset email.
  Future<Result<void, Failure>> forgotPassword(String email);

  /// Resets the password using a token.
  Future<Result<void, Failure>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Verifies the user's email address.
  Future<Result<void, Failure>> verifyEmail(String token);

  /// Gets the currently authenticated user from local storage.
  Future<Result<UserEntity, Failure>> getCurrentUser();

  /// Checks if the user is currently authenticated.
  Future<bool> isAuthenticated();
}
