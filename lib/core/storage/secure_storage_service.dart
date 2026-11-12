import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
              wOptions: WindowsOptions(),
            );

  static const String _keyAccessToken = 'cp_jwt_access_token';
  static const String _keyRefreshToken = 'cp_jwt_refresh_token';
  static const String _keyEmployeeId = 'cp_user_employee_id';
  static const String _keyUserRole = 'cp_user_role';
  static const String _keyUserJson = 'cp_user_profile_json';

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);

  Future<void> saveUserSession({
    required String employeeId,
    required String role,
    required String userJson,
  }) async {
    await _storage.write(key: _keyEmployeeId, value: employeeId);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserJson, value: userJson);
  }

  Future<String?> getEmployeeId() async => await _storage.read(key: _keyEmployeeId);
  Future<String?> getUserRole() async => await _storage.read(key: _keyUserRole);
  Future<String?> getUserJson() async => await _storage.read(key: _keyUserJson);

  Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyEmployeeId);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserJson);
  }
}

