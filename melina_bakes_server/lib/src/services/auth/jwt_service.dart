/// JWT Token Service
///
/// Handles creation and validation of JSON Web Tokens.
/// Implements HS256 signing with secure key management.
///
/// Token structure:
/// - Access tokens: 15 minutes expiry
/// - Refresh tokens: 7 days expiry (hashed in DB)
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';

/// Exception thrown when token validation fails.
class TokenException implements Exception {
  final String message;
  TokenException(this.message);
  @override
  String toString() => 'TokenException: \$message';
}

/// JWT claims extracted from a validated token.
class JwtClaims {
  final int userId;
  final String email;
  final UserRole role;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String jwtId;

  const JwtClaims({
    required this.userId,
    required this.email,
    required this.role,
    required this.issuedAt,
    required this.expiresAt,
    required this.jwtId,
  });

  /// Returns true if the token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Returns remaining time until expiry.
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
}

class JwtService {
  final String _secret;
  final String _issuer;
  final String _audience;
  final _uuid = const Uuid();

  JwtService({
    required String secret,
    String issuer = 'melina-bakes-server',
    String audience = 'melina-bakes-client',
  })  : _secret = secret,
        _issuer = issuer,
        _audience = audience;

  /// Generates a new access token.
  ///
  /// [expiry] defaults to 15 minutes.
  String generateAccessToken({
    required int userId,
    required String email,
    required UserRole role,
    Duration expiry = const Duration(minutes: 15),
  }) {
    final now = DateTime.now().toUtc();
    final header = _base64UrlEncode(jsonEncode({
      'alg': 'HS256',
      'typ': 'JWT',
    }));

    final payload = _base64UrlEncode(jsonEncode({
      'sub': userId.toString(),
      'email': email,
      'role': role.name,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(expiry).millisecondsSinceEpoch ~/ 1000,
      'iss': _issuer,
      'aud': _audience,
      'jti': _uuid.v4(),
    }));

    final signature = _sign('\$header.\$payload');
    return '\$header.\$payload.\$signature';
  }

  /// Generates a cryptographically secure refresh token.
  ///
  /// Returns the raw token (store hashed in DB).
  String generateRefreshToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hashes a refresh token for database storage.
  String hashRefreshToken(String token) {
    final bytes = utf8.encode(token);
    return sha256.convert(bytes).toString();
  }

  /// Validates an access token and returns claims.
  ///
  /// Throws [TokenException] if validation fails.
  JwtClaims validateAccessToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw TokenException('Invalid token format');
      }

      // Verify signature
      final expectedSignature = _sign('\${parts[0]}.\${parts[1]}');
      if (!_constantTimeEquals(parts[2], expectedSignature)) {
        throw TokenException('Invalid signature');
      }

      // Decode payload
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(_base64UrlNormalize(parts[1]))),
      ) as Map<String, dynamic>;

      // Validate issuer and audience
      if (payload['iss'] != _issuer) {
        throw TokenException('Invalid issuer');
      }
      if (payload['aud'] != _audience) {
        throw TokenException('Invalid audience');
      }

      // Check expiry
      final exp = payload['exp'] as int?;
      if (exp == null) {
        throw TokenException('Missing expiry');
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000).toUtc();
      if (DateTime.now().toUtc().isAfter(expiry)) {
        throw TokenException('Token expired');
      }

      return JwtClaims(
        userId: int.parse(payload['sub'] as String),
        email: payload['email'] as String,
        role: UserRole.values.byName(payload['role'] as String),
        issuedAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['iat'] as int) * 1000,
        ).toUtc(),
        expiresAt: expiry,
        jwtId: payload['jti'] as String,
      );
    } on TokenException {
      rethrow;
    } catch (e) {
      throw TokenException('Token validation failed: \$e');
    }
  }

  /// Extracts claims without validating (for logging/debugging).
  JwtClaims? decodeWithoutVerify(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(_base64UrlNormalize(parts[1]))),
      ) as Map<String, dynamic>;

      return JwtClaims(
        userId: int.parse(payload['sub'] as String),
        email: payload['email'] as String,
        role: UserRole.values.byName(payload['role'] as String),
        issuedAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['iat'] as int) * 1000,
        ).toUtc(),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['exp'] as int) * 1000,
        ).toUtc(),
        jwtId: payload['jti'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  /// Signs data with HMAC-SHA256.
  String _sign(String data) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(data));
    return _base64UrlEncode(digest.bytes);
  }

  /// Base64URL encodes a string or byte array.
  String _base64UrlEncode(dynamic input) {
    if (input is String) {
      return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
    }
    return base64Url.encode(input as List<int>).replaceAll('=', '');
  }

  /// Normalizes base64url string for decoding.
  String _base64UrlNormalize(String input) {
    final padding = 4 - (input.length % 4);
    if (padding != 4) {
      return input + ('=' * padding);
    }
    return input;
  }

  /// Constant-time string comparison to prevent timing attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
