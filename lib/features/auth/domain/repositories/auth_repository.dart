import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String employeeId,
    required String password,
  });

  Future<User> register({
    required String employeeId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
    required String plantUnit,
  });

  Future<User?> getCurrentUser();

  Future<void> logout();

  Future<bool> isAuthenticated();
}

