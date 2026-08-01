
/// Implementation of [AuthRepository] that coordinates remote
/// and local data sources.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<UserEntity, Failure>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
      );
      await _localDataSource.saveUser(response.user);

      return Success(response.user.toEntity());
    } on AuthFailure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity, Failure>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
      );
      await _localDataSource.saveUser(response.user);

      return Success(response.user.toEntity());
    } on AuthFailure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity, Failure>> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return const FailureResult(AuthFailure(message: 'No refresh token available'));
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
      );
      await _localDataSource.saveUser(response.user);

      return Success(response.user.toEntity());
    } on AuthFailure catch (e) {
      return FailureResult(e);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearTokens();
      await _localDataSource.clearUser();
      return const Success(null);
    } catch (e) {
      await _localDataSource.clearTokens();
      await _localDataSource.clearUser();
      return const Success(null);
    }
  }

  @override
  Future<Result<void, Failure>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(token: token, newPassword: newPassword);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> verifyEmail(String token) async {
    try {
      await _remoteDataSource.verifyEmail(token);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity, Failure>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getUser();
      if (user == null) {
        return const FailureResult(NotFoundFailure(message: 'No user session found'));
      }
      return Success(user.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.hasValidTokens();
  }
}
