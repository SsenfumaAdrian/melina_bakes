/// User Repository Interface
/// 
/// Defines the contract for user data access operations.
/// Implementations handle the actual database interaction.
///
/// Follows the Repository Pattern for testability and
/// swappable data sources.
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../generated/user.dart';

abstract interface class UserRepository {
  /// Creates a new user account.
  /// 
  /// Returns the created [User] or a [Failure] if:
  /// - Email already exists ([ConflictFailure])
  /// - Validation fails ([ValidationFailure])
  Future<Result<User, Failure>> createUser({
    required String email,
    required String passwordHash,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  });

  /// Finds a user by their unique email address.
  /// 
  /// Returns [NotFoundFailure] if no user exists with the given email.
  Future<Result<User, Failure>> findByEmail(String email);

  /// Finds a user by their ID.
  Future<Result<User, Failure>> findById(int id);

  /// Updates user profile information.
  Future<Result<User, Failure>> updateProfile({
    required int userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
  });

  /// Updates the user's password hash.
  Future<Result<void, Failure>> updatePassword({
    required int userId,
    required String newPasswordHash,
  });

  /// Records a successful login attempt.
  Future<Result<void, Failure>> recordLogin({
    required int userId,
    required String ipAddress,
  });

  /// Records a failed login attempt and potentially locks the account.
  Future<Result<void, Failure>> recordFailedLogin({
    required int userId,
    required int maxAttempts,
    required Duration lockoutDuration,
  });

  /// Verifies the user's email address.
  Future<Result<void, Failure>> verifyEmail(int userId);

  /// Soft deletes a user account.
  Future<Result<void, Failure>> softDelete(int userId);

  /// Lists users with pagination and filtering.
  Future<Result<PaginatedResponse<User>, Failure>> listUsers({
    required int page,
    required int pageSize,
    UserRole? roleFilter,
    bool? isActive,
    String? searchQuery,
  });
}
