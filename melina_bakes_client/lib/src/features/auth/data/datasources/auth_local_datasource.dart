
/// Local data source for authentication persistence.
///
/// Stores tokens and user profile in secure/shared preferences.
library;

import 'dart:convert';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  });

  Future<void> clearTokens();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clearUser();

  Future<bool> hasValidTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final StorageService _sharedStorage;

  AuthLocalDataSourceImpl({
    required SecureStorageService secureStorage,
    required StorageService sharedStorage,
  })  : _secureStorage = secureStorage,
        _sharedStorage = sharedStorage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    await _secureStorage.setString(StorageKeys.accessToken, accessToken);
    await _secureStorage.setString(StorageKeys.refreshToken, refreshToken);

    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await _secureStorage.setString(
      StorageKeys.tokenExpiry,
      expiry.millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.remove(StorageKeys.accessToken);
    await _secureStorage.remove(StorageKeys.refreshToken);
    await _secureStorage.remove(StorageKeys.tokenExpiry);
  }

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.getString(StorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.getString(StorageKeys.refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _sharedStorage.setString(StorageKeys.userData, json);
  }

  @override
  Future<UserModel?> getUser() async {
    final json = await _sharedStorage.getString(StorageKeys.userData);
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _sharedStorage.remove(StorageKeys.userData);
  }

  @override
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final expiryStr = await _secureStorage.getString(StorageKeys.tokenExpiry);

    if (accessToken == null || accessToken.isEmpty) return false;
    if (expiryStr == null) return false;

    try {
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }
}
