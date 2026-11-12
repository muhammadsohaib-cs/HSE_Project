import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User> login({
    required String employeeId,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      employeeId: employeeId,
      password: password,
    );

    await _localDataSource.saveUserSession(
      user: result.user,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    return result.user;
  }

  @override
  Future<User> register({
    required String employeeId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
    required String plantUnit,
  }) async {
    final result = await _remoteDataSource.register(
      employeeId: employeeId,
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
      plantUnit: plantUnit,
    );

    await _localDataSource.saveUserSession(
      user: result.user,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    return result.user;
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _localDataSource.getCachedUser();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

