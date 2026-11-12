import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  static bool get isWeb => kIsWeb;

  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isMobile => isAndroid || isIOS;

  static String get platformName {
    if (kIsWeb) return 'Web';
    if (isWindows) return 'Windows Desktop';
    if (isMacOS) return 'macOS Desktop';
    if (isLinux) return 'Linux Desktop';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Whether device has physical camera hardware typical of field units
  static bool get hasCameraSupport => isMobile;

  /// Whether device typically has onboard GPS hardware
  static bool get hasNativeGps => isMobile;
}

