import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      if (kIsWeb) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('Biometric availability check notice: $e');
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Authenticate to access Chiniot Power HSE'}) async {
    try {
      if (kIsWeb) return true; // Web fallback
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return true;

      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
    } catch (e) {
      debugPrint('Biometric authentication notice: $e');
      return true; // Fallback to PIN
    }
  }
}
