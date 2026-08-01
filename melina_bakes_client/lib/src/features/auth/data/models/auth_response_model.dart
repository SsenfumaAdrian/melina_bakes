
/// Model representing the server's auth response.
library;

import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json;
    return AuthResponseModel(
      accessToken: data['accessToken'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      expiresIn: data['expiresIn'] as int? ?? 900,
      tokenType: data['tokenType'] as String? ?? 'Bearer',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
