
/// Injects JWT access token into outgoing requests.
library;

import 'package:dio/dio.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['skipAuth'] == true) return handler.next(options);
    final token = await _secureStorage.getString(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
