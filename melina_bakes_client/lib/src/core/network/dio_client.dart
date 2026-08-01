
/// Dio HTTP client configuration.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) => createDioClient());

Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );
}
