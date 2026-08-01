
/// Authentication state management using Riverpod.
///
/// Provides reactive auth state, login/register actions,
/// and logout functionality across the application.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provider for the auth controller (state notifier).
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

/// Provider that exposes whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider) is AuthenticatedAuthState,
);

/// Provider that exposes the current user (or null).
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authControllerProvider);
  if (state is AuthenticatedAuthState) {
    return state.user;
  }
  return null;
});

/// Provider that exposes the current user's role.
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role ?? UserRole.guest;
});

/// Base class for all authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state before auth status is determined.
class InitialAuthState extends AuthState {
  const InitialAuthState();
}

/// Loading state during auth operations.
class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

/// Authenticated state with user data.
class AuthenticatedAuthState extends AuthState {
  final UserEntity user;

  const AuthenticatedAuthState(this.user);
}

/// Unauthenticated state (guest or logged out).
class UnauthenticatedAuthState extends AuthState {
  final String? message;

  const UnauthenticatedAuthState({this.message});
}

/// Error state when auth operation fails.
class ErrorAuthState extends AuthState {
  final String message;

  const ErrorAuthState(this.message);
}

/// Controller that manages authentication state and operations.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const InitialAuthState()) {
    _checkAuthStatus();
  }

  /// Checks if the user has a valid existing session.
  Future<void> _checkAuthStatus() async {
    state = const LoadingAuthState();
    final isAuth = await _repository.isAuthenticated();
    if (isAuth) {
      final result = await _repository.getCurrentUser();
      result.when(
        success: (user) => state = AuthenticatedAuthState(user),
        failure: (_) => state = const UnauthenticatedAuthState(),
      );
    } else {
      state = const UnauthenticatedAuthState();
    }
  }

  /// Logs in with email and password.
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const LoadingAuthState();
    final result = await _repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    result.when(
      success: (user) => state = AuthenticatedAuthState(user),
      failure: (failure) => state = ErrorAuthState(failure.message),
    );
  }

  /// Registers a new account.
  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    state = const LoadingAuthState();
    final result = await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    result.when(
      success: (user) => state = AuthenticatedAuthState(user),
      failure: (failure) => state = ErrorAuthState(failure.message),
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    state = const LoadingAuthState();
    await _repository.logout();
    state = const UnauthenticatedAuthState(message: 'Logged out successfully');
  }

  /// Clears any error state.
  void clearError() {
    if (state is ErrorAuthState) {
      state = const UnauthenticatedAuthState();
    }
  }
}
