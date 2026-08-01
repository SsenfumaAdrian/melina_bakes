
/// Standardizes error responses into typed exceptions.
library;

import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    if (res != null) {
      final d = res.data as Map<String, dynamic>?;
      final msg = d?['error']?['message'] ?? d?['message'] ?? 'An error occurred';
      final code = d?['error']?['code'] as String?;
      switch (res.statusCode) {
        case 400:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: ValidationException(msg, code: code));
          break;
        case 401:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: AuthException(msg, code: code));
          break;
        case 403:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: AppException(msg, code: code ?? 'FORBIDDEN'));
          break;
        case 404:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: NotFoundException(msg, code: code));
          break;
        case 422:
          final fe = (d?['error']?['fields'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString()));
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: ValidationException(msg, fieldErrors: fe, code: code));
          break;
        case 429:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: AppException(msg, code: code ?? 'RATE_LIMITED'));
          break;
        case 500: case 502: case 503:
          err = DioException(requestOptions: err.requestOptions, response: res, type: err.type,
            error: ServerException(msg, statusCode: res.statusCode!, responseData: d, code: code));
          break;
      }
    }
    handler.next(err);
  }
}
