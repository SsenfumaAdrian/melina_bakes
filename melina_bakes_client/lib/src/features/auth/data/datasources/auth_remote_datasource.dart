
/// Remote data source for authentication API calls.
///
/// Communicates with the Serverpod auth endpoints via Dio.
library;

import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> refreshToken(String refreshToken);

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> verifyEmail(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final result = await _apiClient.post<AuthResponseModel>(
      '/auth/register',
      parser: (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>),
      data: {
        'email': email,
        'password': password,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );

    return result.when(
      success: (value) => value,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final result = await _apiClient.post<AuthResponseModel>(
      '/auth/login',
      parser: (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>),
      data: {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      },
    );

    return result.when(
      success: (value) => value,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final result = await _apiClient.post<AuthResponseModel>(
      '/auth/refresh',
      parser: (data) => AuthResponseModel.fromJson(data as Map<String, dynamic>),
      data: {'refreshToken': refreshToken},
    );

    return result.when(
      success: (value) => value,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> logout() async {
    final result = await _apiClient.post<void>(
      '/auth/logout',
      parser: (_) {},
    );

    result.when(
      success: (_) {},
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    final result = await _apiClient.post<void>(
      '/auth/forgot-password',
      parser: (_) {},
      data: {'email': email},
    );

    result.when(
      success: (_) {},
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final result = await _apiClient.post<void>(
      '/auth/reset-password',
      parser: (_) {},
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    result.when(
      success: (_) {},
      failure: (failure) => throw Exception(failure.message),
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    final result = await _apiClient.post<void>(
      '/auth/verify-email',
      parser: (_) {},
      data: {'token': token},
    );

    result.when(
      success: (_) {},
      failure: (failure) => throw Exception(failure.message),
    );
  }
}
