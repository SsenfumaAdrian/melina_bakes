
/// Handles 401 responses by refreshing the access token.
library;

import 'package:dio/dio.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../services/storage_service.dart';

class RefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  bool _isRefreshing = false;
  final List<Function()> _pending = [];

  RefreshInterceptor(this._dio, this._secureStorage);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    final original = err.requestOptions;
    if (original.path.startsWith('/auth')) return handler.next(err);

    if (_isRefreshing) {
      _pending.add(() async {
        final t = _dio.options.headers['Authorization'] as String?;
        original.headers['Authorization'] = t;
        final res = await _dio.fetch(original);
        handler.resolve(res);
      });
      return;
    }

    _isRefreshing = true;
    try {
      final rt = await _secureStorage.getString(StorageKeys.refreshToken);
      if (rt == null || rt.isEmpty) {
        await _clear();
        return handler.next(err);
      }
      final res = await _dio.post('/auth/refresh',
        data: {'refreshToken': rt},
        options: Options(extra: {'skipAuth': true, 'skipRefresh': true}),
      );
      final data = res.data as Map<String, dynamic>?;
      if (data?['success'] == true) {
        final at = data!['data']['accessToken'] as String?;
        final nrt = data['data']['refreshToken'] as String?;
        if (at != null) {
          await _secureStorage.setString(StorageKeys.accessToken, at);
          _dio.options.headers['Authorization'] = 'Bearer $at';
        }
        if (nrt != null) await _secureStorage.setString(StorageKeys.refreshToken, nrt);
        original.headers['Authorization'] = 'Bearer $at';
        final retry = await _dio.fetch(original);
        handler.resolve(retry);
        for (final p in _pending) p();
        _pending.clear();
      } else {
        await _clear();
        handler.next(err);
      }
    } catch (_) {
      await _clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clear() async {
    await _secureStorage.remove(StorageKeys.accessToken);
    await _secureStorage.remove(StorageKeys.refreshToken);
    await _secureStorage.remove(StorageKeys.tokenExpiry);
  }
}
