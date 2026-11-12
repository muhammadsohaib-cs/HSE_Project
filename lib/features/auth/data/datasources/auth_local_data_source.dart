import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserSession({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  });
  Future<UserModel?> getCachedUser();
  Future<String?> getAccessToken();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  AuthLocalDataSourceImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> saveUserSession({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _secureStorage.saveUserSession(
      employeeId: user.employeeId,
      role: user.role.name,
      userJson: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = await _secureStorage.getUserJson();
    if (userJson == null) return null;
    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async => await _secureStorage.getAccessToken();

  @override
  Future<void> clearSession() async => await _secureStorage.clearSession();
}

