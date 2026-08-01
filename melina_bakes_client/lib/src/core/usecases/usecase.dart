
/// Base class for all use cases in the application.
///
/// Use cases encapsulate a single business operation and
/// promote reusability across features.
///
/// Example:
/// ```dart
/// class LoginUseCase implements UseCase<UserEntity, LoginParams> {
///   final AuthRepository _repository;
///   LoginUseCase(this._repository);
///
///   @override
///   Future<Result<UserEntity, Failure>> call(LoginParams params) {
///     return _repository.login(params.email, params.password);
///   }
/// }
/// ```
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';

/// Interface for use cases with parameters.
abstract interface class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  Future<Result<Type, Failure>> call(Params params);
}

/// Interface for use cases without parameters.
abstract interface class NoParamsUseCase<Type> {
  /// Executes the use case.
  Future<Result<Type, Failure>> call();
}

/// Marker class for use cases that require no parameters.
final class NoParams {
  const NoParams();
}
