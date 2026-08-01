
/// High-level API client with Result<T, Failure> envelope.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../errors/exceptions.dart';
import 'dio_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  const ApiResponse({required this.success, this.data, this.message, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) parser) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null ? parser(json['data']) : null,
      message: json['message'] as String?,
      error: json['error'] != null ? ApiError.fromJson(json['error'] as Map<String, dynamic>) : null,
    );
  }
}

class ApiError {
  final String? code;
  final String message;
  const ApiError({this.code, required this.message});
  factory ApiError.fromJson(Map<String, dynamic> json) =>
      ApiError(code: json['code'] as String?, message: json['message'] as String? ?? 'Unknown error');
}

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<Result<T, Failure>> get<T>(String path, {required T Function(dynamic) parser, Map<String, dynamic>? query}) async {
    return _request(() => _dio.get(path, queryParameters: query), parser);
  }

  Future<Result<T, Failure>> post<T>(String path, {required T Function(dynamic) parser, dynamic data, Map<String, dynamic>? query}) async {
    return _request(() => _dio.post(path, data: data, queryParameters: query), parser);
  }

  Future<Result<T, Failure>> put<T>(String path, {required T Function(dynamic) parser, dynamic data}) async {
    return _request(() => _dio.put(path, data: data), parser);
  }

  Future<Result<T, Failure>> delete<T>(String path, {required T Function(dynamic) parser, dynamic data}) async {
    return _request(() => _dio.delete(path, data: data), parser);
  }

  Future<Result<T, Failure>> patch<T>(String path, {required T Function(dynamic) parser, dynamic data}) async {
    return _request(() => _dio.patch(path, data: data), parser);
  }

  Future<Result<T, Failure>> _request<T>(Future<Response> Function() req, T Function(dynamic) parser) async {
    try {
      final res = await req();
      final body = res.data as Map<String, dynamic>? ?? {};
      final api = ApiResponse<T>.fromJson(body, parser);
      if (api.success && api.data != null) return Success(api.data as T);
      return FailureResult(ServerFailure(message: api.error?.message ?? api.message ?? 'Request failed', code: api.error?.code));
    } on DioException catch (e) {
      return FailureResult(_mapDio(e));
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Failure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'No internet connection. Please check your network.');
      case DioExceptionType.badResponse:
        final sc = e.response?.statusCode;
        final d = e.response?.data as Map<String, dynamic>?;
        final msg = d?['error']?['message'] ?? d?['message'] ?? 'Server error';
        final code = d?['error']?['code'] as String?;
        if (sc == 401) return AuthFailure(message: msg, code: code);
        if (sc == 403) return ForbiddenFailure(message: msg, code: code);
        if (sc == 404) return NotFoundFailure(message: msg, code: code);
        if (sc == 409) return ConflictFailure(message: msg, code: code);
        if (sc == 422) return ValidationFailure(message: msg, code: code);
        if (sc == 429) return RateLimitFailure(message: msg, code: code);
        return ServerFailure(message: msg, code: code);
      case DioExceptionType.badCertificate:
        return const NetworkFailure(message: 'SSL certificate error. Please check your connection.');
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled.');
      case DioExceptionType.unknown:
        return NetworkFailure(message: 'Network error: ${e.message}');
    }
  }
}
