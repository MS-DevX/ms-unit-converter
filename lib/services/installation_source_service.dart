/// Detects the installation source of the app to tailor update experiences.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provides information about how and where the app was installed from.
class InstallationSourceService {
  InstallationSourceService._();

  /// Singleton instance.
  static final InstallationSourceService instance =
      InstallationSourceService._();

  /// The Google Play Store installer package name on Android.
  static const String _playStoreInstaller = 'com.android.vending';

  /// Platform channel for querying the Android installer package.
  static const _channel = MethodChannel(
    'com.msdevx.unitconverter/installer_source',
  );

  bool? _isFromPlayStore;

  /// Whether the app was installed from the Google Play Store.
  ///
  /// Returns `false` on non-Android platforms, debug builds, or if detection fails.
  Future<bool> get isFromPlayStore async {
    if (_isFromPlayStore != null) return _isFromPlayStore!;
    _isFromPlayStore = await _detect();
    return _isFromPlayStore!;
  }

  /// Detects the installation source by querying the platform installer package.
  Future<bool> _detect() async {
    try {
      if (!Platform.isAndroid) return false;

      final info = await PackageInfo.fromPlatform();

      debugPrint('[InstallationSource] Package: ${info.packageName}');

      final installer = await _getAndroidInstaller(info.packageName);
      debugPrint('[InstallationSource] Installer: $installer');

      return installer == _playStoreInstaller;
    } catch (e) {
      debugPrint('[InstallationSource] Detection failed: $e');
      return false;
    }
  }

  /// Queries the Android PackageManager for the installer package name.
  Future<String?> _getAndroidInstaller(String packageName) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getInstallerPackageName',
        {'packageName': packageName},
      );
      return result;
    } catch (e) {
      debugPrint('[InstallationSource] MethodChannel error: $e');
      return null;
    }
  }

  /// Resets the cached detection result (useful for testing).
  void resetCache() {
    _isFromPlayStore = null;
  }
}
