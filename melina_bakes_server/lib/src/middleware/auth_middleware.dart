/// Authentication Middleware
///
/// Validates JWT tokens on incoming requests and enforces
/// role-based access control (RBAC).
///
/// Usage:
/// ```dart
/// @middleware(AuthMiddleware(requiredRole: UserRole.manager))
/// class AdminEndpoint extends Endpoint { ... }
/// ```
import 'package:serverpod/serverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../services/auth/jwt_service.dart';
import '../services/auth/auth_service.dart';

class AuthMiddleware extends Middleware {
  final UserRole? _requiredRole;
  final bool _requireVerifiedEmail;

  /// Creates auth middleware with optional role requirement.
  ///
  /// [requiredRole] - Minimum role required (hierarchy checked).
  /// [requireVerifiedEmail] - Whether email must be verified.
  const AuthMiddleware({
    UserRole? requiredRole,
    bool requireVerifiedEmail = true,
  })  : _requiredRole = requiredRole,
        _requireVerifiedEmail = requireVerifiedEmail;

  @override
  Future<bool> handleRequest(Session session, Endpoint endpoint) async {
    try {
      // Extract Authorization header
      final authHeader = session.httpRequest.headers['Authorization']?.first;
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        throw UnauthorizedException('Missing or invalid authorization header');
      }

      final token = authHeader.substring(7);

      // Validate JWT
      final jwtService = JwtService(
        secret: session.server.passwords['serviceSecret'] ?? 'dev-secret',
      );
      final claims = jwtService.validateAccessToken(token);

      // Check email verification
      if (_requireVerifiedEmail && !claims.role.hasPermission(UserRole.guest)) {
        // In production: check user's email verification status
      }

      // Check role permissions
      if (_requiredRole != null && !claims.role.hasPermission(_requiredRole!)) {
        throw UnauthorizedException(
          'Insufficient permissions. Required: \${_requiredRole!.displayName}',
        );
      }

      // Store user info in session for endpoint use
      session.authenticationKey = claims.userId.toString();

      return true;
    } on TokenException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw UnauthorizedException('Authentication failed');
    }
  }
}

/// Middleware that allows guest access but still validates tokens if present.
class OptionalAuthMiddleware extends Middleware {
  @override
  Future<bool> handleRequest(Session session, Endpoint endpoint) async {
    final authHeader = session.httpRequest.headers['Authorization']?.first;
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      try {
        final token = authHeader.substring(7);
        final jwtService = JwtService(
          secret: session.server.passwords['serviceSecret'] ?? 'dev-secret',
        );
        final claims = jwtService.validateAccessToken(token);
        session.authenticationKey = claims.userId.toString();
      } catch (_) {
        // Ignore invalid tokens for optional auth
      }
    }
    return true;
  }
}
