/// A type representing either a success value [R] or a failure [Failure].
///
/// Inspired by functional programming's Either type, this Result type
/// forces explicit error handling and eliminates null checks.
///
/// Example:
/// ```dart
/// Result<User, AuthFailure> result = await authRepository.login(email, password);
/// result.when(
///   success: (user) => navigateToHome(user),
///   failure: (failure) => showError(failure.message),
/// );
/// ```
sealed class Result<R, F extends Failure> {
  const Result();

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<R, F>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is FailureResult<R, F>;

  /// Returns the success value or null.
  R? get valueOrNull => isSuccess ? (this as Success<R, F>).value : null;

  /// Returns the failure or null.
  F? get failureOrNull => isFailure ? (this as FailureResult<R, F>).failure : null;

  /// Maps the success value using [transform].
  Result<T, F> map<T>(T Function(R value) transform) {
    return when(
      success: (value) => Success(transform(value)),
      failure: (failure) => FailureResult(failure),
    );
  }

  /// Executes [onSuccess] if this is a [Success], otherwise [onFailure].
  T when<T>({
    required T Function(R value) success,
    required T Function(F failure) failure,
  });

  /// Executes [onSuccess] if this is a [Success], otherwise returns [orElse].
  T maybeWhen<T>({
    T Function(R value)? success,
    T Function(F failure)? failure,
    required T Function() orElse,
  }) {
    return when(
      success: (value) => success != null ? success(value) : orElse(),
      failure: (fail) => failure != null ? failure(fail) : orElse(),
    );
  }
}

/// Represents a successful operation with a value of type [R].
final class Success<R, F extends Failure> extends Result<R, F> {
  /// The success value.
  final R value;

  const Success(this.value);

  @override
  T when<T>({
    required T Function(R value) success,
    required T Function(F failure) failure,
  }) =>
      success(value);
}

/// Represents a failed operation with a [Failure].
final class FailureResult<R, F extends Failure> extends Result<R, F> {
  /// The failure details.
  final F failure;

  const FailureResult(this.failure);

  @override
  T when<T>({
    required T Function(R value) success,
    required T Function(F failure) failure,
  }) =>
      failure(this.failure);
}

/// Base class for all failures in the application.
///
/// Each feature domain should define its own concrete failure types
/// extending this base class.
abstract class Failure {
  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Optional additional context or data.
  final Map<String, dynamic>? context;

  const Failure({
    required this.message,
    this.code,
    this.context,
  });

  @override
  String toString() => 'Failure(message: \$message, code: \$code)';
}

/// Common failures used across multiple domains.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed. Please check your internet.',
    super.code = 'NETWORK_ERROR',
  });
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
    this.statusCode,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed. Please check your input.',
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'You are not authorized to perform this action.',
    super.code = 'UNAUTHORIZED',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'A conflict occurred with the current state.',
    super.code = 'CONFLICT',
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The operation timed out. Please try again.',
    super.code = 'TIMEOUT',
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
  });
}
