import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<User> execute({
    required String employeeId,
    required String password,
  }) async {
    final formattedId = employeeId.trim().toUpperCase();
    if (!User.isValidEmployeeId(formattedId)) {
      throw const ValidationFailure('Employee ID must follow standard format: CP-EMP-XXXX');
    }
    if (password.trim().isEmpty) {
      throw const ValidationFailure('Password is required');
    }
    return await repository.login(employeeId: formattedId, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<User> execute({
    required String employeeId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
    required String plantUnit,
  }) async {
    final formattedId = employeeId.trim().toUpperCase();
    if (!User.isValidEmployeeId(formattedId)) {
      throw const ValidationFailure('Employee ID must follow standard format: CP-EMP-XXXX');
    }
    if (name.trim().isEmpty) {
      throw const ValidationFailure('Full employee name is required');
    }
    return await repository.register(
      employeeId: formattedId,
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
      plantUnit: plantUnit,
    );
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> execute() async => await repository.logout();
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<User?> execute() async => await repository.getCurrentUser();
}

