
/// Logs requests and responses using the Logger package.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80, colors: true, printEmojis: true),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('➡️  REQUEST: ${options.method} ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) _logger.d('Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}', error: err.message, stackTrace: err.stackTrace);
    if (err.response?.data != null) _logger.d('Error Data: ${err.response?.data}');
    handler.next(err);
  }
}
