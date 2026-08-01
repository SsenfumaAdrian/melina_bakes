
/// Core exceptions used across the application.
///
/// These exceptions are thrown by data sources and caught
/// by repositories to be mapped into [Failure] objects.
library;

/// Base exception for all application-specific errors.
class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => 'AppException[$code]: $message';
}

/// Exception thrown when a network request fails.
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.stackTrace,
  });

  @override
  String toString() =>
      'NetworkException[${statusCode ?? 'unknown'}]: $message';
}

/// Exception thrown when the server returns an error response.
class ServerException extends AppException {
  final int statusCode;
  final Map<String, dynamic>? responseData;

  const ServerException(
    super.message, {
    required this.statusCode,
    this.responseData,
    super.code,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException[$statusCode]: $message';
}

/// Exception thrown when authentication fails or token is invalid.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when input validation fails.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when a timeout occurs.
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.stackTrace});
}

/// Exception thrown when a cache operation fails.
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.stackTrace});
}
