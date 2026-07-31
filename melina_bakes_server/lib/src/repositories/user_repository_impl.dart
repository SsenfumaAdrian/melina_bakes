/// User Repository Implementation
///
/// Serverpod ORM-based implementation of [UserRepository].
import 'package:serverpod/serverpod.dart';
import 'package:melina_bakes_shared/melina_bakes_shared.dart';
import '../../generated/user.dart';
import '../user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Session _session;

  UserRepositoryImpl(this._session);

  @override
  Future<Result<User, Failure>> createUser({
    required String email,
    required String passwordHash,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final existing = await User.find(
        _session,
        where: (t) => t.email.equals(email) & t.deletedAt.isNull(),
      );

      if (existing != null) {
        return const FailureResult(
          ConflictFailure(message: 'An account with this email already exists.'),
        );
      }

      final user = User(
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
      );

      await User.insert(_session, user);
      return Success(user);
    } catch (e) {
      return FailureResult(
        ServerFailure(message: 'Failed to create user: $e'),
      );
    }
  }

  @override
  Future<Result<User, Failure>> findByEmail(String email) async {
    try {
      final user = await User.find(
        _session,
        where: (t) => t.email.equals(email.toLowerCase().trim()) & t.deletedAt.isNull(),
      );

      if (user == null) {
        return const FailureResult(NotFoundFailure());
      }

      return Success(user);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Database error: $e'));
    }
  }

  @override
  Future<Result<User, Failure>> findById(int id) async {
    try {
      final user = await User.findById(_session, id);

      if (user == null || user.deletedAt != null) {
        return const FailureResult(NotFoundFailure());
      }

      return Success(user);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Database error: $e'));
    }
  }

  @override
  Future<Result<User, Failure>> updateProfile({
    required int userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) {
        return const FailureResult(NotFoundFailure());
      }

      if (firstName != null) user.firstName = firstName;
      if (lastName != null) user.lastName = lastName;
      if (phoneNumber != null) user.phoneNumber = phoneNumber;
      if (avatarUrl != null) user.avatarUrl = avatarUrl;

      await User.update(_session, user);
      return Success(user);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Update failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> updatePassword({
    required int userId,
    required String newPasswordHash,
  }) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) {
        return const FailureResult(NotFoundFailure());
      }

      user.passwordHash = newPasswordHash;
      await User.update(_session, user);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Password update failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> recordLogin({
    required int userId,
    required String ipAddress,
  }) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) return const Success(null);

      user.lastLoginAt = DateTime.now();
      user.lastLoginIp = ipAddress;
      user.failedLoginAttempts = 0;
      user.lockedUntil = null;

      await User.update(_session, user);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Login record failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> recordFailedLogin({
    required int userId,
    required int maxAttempts,
    required Duration lockoutDuration,
  }) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) return const Success(null);

      user.failedLoginAttempts++;

      if (user.failedLoginAttempts >= maxAttempts) {
        user.lockedUntil = DateTime.now().add(lockoutDuration);
      }

      await User.update(_session, user);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Failed login record failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> verifyEmail(int userId) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) {
        return const FailureResult(NotFoundFailure());
      }

      user.isEmailVerified = true;
      await User.update(_session, user);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Email verification failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> softDelete(int userId) async {
    try {
      final user = await User.findById(_session, userId);
      if (user == null) {
        return const FailureResult(NotFoundFailure());
      }

      user.deletedAt = DateTime.now();
      user.isActive = false;
      user.email = '${user.email}.deleted.${user.id}';

      await User.update(_session, user);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(message: 'Soft delete failed: $e'));
    }
  }

  @override
  Future<Result<PaginatedResponse<User>, Failure>> listUsers({
    required int page,
    required int pageSize,
    UserRole? roleFilter,
    bool? isActive,
    String? searchQuery,
  }) async {
    try {
      final users = await User.find(
        _session,
        where: (t) => t.deletedAt.isNull(),
      );

      final total = users?.length ?? 0;
      final totalPages = (total / pageSize).ceil();

      return Success(PaginatedResponse(
        items: users ?? [],
        page: page,
        pageSize: pageSize,
        totalItems: total,
        totalPages: totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      ));
    } catch (e) {
      return FailureResult(ServerFailure(message: 'List failed: $e'));
    }
  }
}
