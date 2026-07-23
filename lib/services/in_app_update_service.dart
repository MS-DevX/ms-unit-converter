/// In-App Update Service for Google Play Store updates.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

/// Supported update modes for Google Play In-App Updates.
enum AppUpdateMode {
  /// Flexible update: downloads in background while app is usable.
  flexible,

  /// Immediate update: fullscreen update flow; app unusable until update completes.
  immediate,
}

/// Production-ready In-App Update Service managing Google Play Store updates.
class InAppUpdateService {
  InAppUpdateService._();

  /// Singleton instance of [InAppUpdateService].
  static final InAppUpdateService instance = InAppUpdateService._();

  /// Configurable update mode. Default is [AppUpdateMode.flexible].
  AppUpdateMode updateMode = AppUpdateMode.flexible;

  bool _isChecking = false;

  /// Checks for Google Play updates and triggers native update flow if available.
  ///
  /// Safe to call on app startup or lifecycle resume; never throws or crashes.
  Future<void> checkForUpdate({
    BuildContext? context,
    AppUpdateMode? overrideMode,
  }) async {
    if (_isChecking) return;
    _isChecking = true;

    final targetMode = overrideMode ?? updateMode;

    try {
      debugPrint('[InAppUpdate] Checking for updates via Google Play Store...');
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        debugPrint(
          '[InAppUpdate] Update available (Version code: ${info.availableVersionCode})',
        );

        if (targetMode == AppUpdateMode.immediate &&
            info.immediateUpdateAllowed) {
          debugPrint('[InAppUpdate] Starting Immediate Update flow...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          debugPrint('[InAppUpdate] Starting Flexible Update flow...');
          final result = await InAppUpdate.startFlexibleUpdate();

          if (result == AppUpdateResult.success) {
            debugPrint('[InAppUpdate] Flexible update downloaded successfully.');
            if (context != null && context.mounted) {
              _promptFlexibleUpdateComplete(context);
            }
          }
        }
      } else if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        debugPrint('[InAppUpdate] Developer triggered update in progress.');
        if (targetMode == AppUpdateMode.immediate &&
            info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
      } else {
        debugPrint('[InAppUpdate] No update available or update not allowed.');
      }
    } on PlatformException catch (e) {
      // Handles cases where Play Store is unavailable, un-signed debug builds, etc.
      debugPrint('[InAppUpdate] Play Store API error: ${e.code} — ${e.message}');
    } catch (e) {
      debugPrint('[InAppUpdate] Unexpected update error: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Displays a Material 3 SnackBar informing the user that the flexible download
  /// is complete, offering a "RESTART" action to finish updating.
  void _promptFlexibleUpdateComplete(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'An update has been downloaded. Restart to finish updating.',
          style: TextStyle(fontSize: 14),
        ),
        duration: const Duration(days: 1), // Persistent until action tapped
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RESTART',
          onPressed: () async {
            try {
              await InAppUpdate.completeFlexibleUpdate();
            } catch (e) {
              debugPrint('[InAppUpdate] Failed to complete flexible update: $e');
            }
          },
        ),
      ),
    );
  }

  /// Manually triggers immediate update flow if available.
  Future<bool> performImmediateUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }
    } catch (e) {
      debugPrint('[InAppUpdate] Immediate update error: $e');
    }
    return false;
  }
}
