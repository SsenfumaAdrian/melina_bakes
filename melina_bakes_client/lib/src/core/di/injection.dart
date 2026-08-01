
/// Dependency injection wiring using Riverpod.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/refresh_interceptor.dart';
import '../services/storage_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final configuredDioProvider = Provider<Dio>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  dio.interceptors.addAll([
    AuthInterceptor(secureStorage),
    RefreshInterceptor(dio, secureStorage),
    ErrorInterceptor(),
    LoggingInterceptor(),
  ]);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(configuredDioProvider)));

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSourceImpl(ref.watch(apiClientProvider)));

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) => AuthLocalDataSourceImpl(
  secureStorage: ref.watch(secureStorageProvider),
  sharedStorage: ref.watch(sharedStorageProvider),
));

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  localDataSource: ref.watch(authLocalDataSourceProvider),
));
