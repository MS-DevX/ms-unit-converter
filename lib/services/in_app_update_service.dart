/// In-App Update Service for Google Play Store updates.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import 'installation_source_service.dart';

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
  /// If the app was not installed from the Play Store, shows a friendly dialog
  /// guiding the user to install the official version.
  Future<void> checkForUpdate({
    BuildContext? context,
    AppUpdateMode? overrideMode,
  }) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final isPlayStore =
          await InstallationSourceService.instance.isFromPlayStore;

      if (!isPlayStore) {
        _isChecking = false;
        if (!kIsWeb && context != null && context.mounted) {
          _showPlayStoreDialog(context);
        }
        return;
      }

      await _performUpdateCheck(
        context: context?.mounted == true ? context : null,
        overrideMode: overrideMode,
      );
    } finally {
      _isChecking = false;
    }
  }

  /// Runs the actual Play Store in-app update check.
  Future<void> _performUpdateCheck({
    BuildContext? context,
    AppUpdateMode? overrideMode,
  }) async {
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
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You\'re using the latest version.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[InAppUpdate] Play Store API error: ${e.code} — ${e.message}');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to check for updates. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[InAppUpdate] Unexpected update error: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Shows a friendly dialog when the app was not installed from Google Play.
  void _showPlayStoreDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Icon(
          Icons.system_update_rounded,
          color: colorScheme.primary,
          size: 32,
        ),
        title: Text(
          'Get Updates from Google Play',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "You're using a version of Unit Converter that wasn't installed from Google Play.\n\n"
          'To receive automatic update notifications, new features, bug fixes, and security improvements, '
          'please install the official version from the Google Play Store.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: const Text('Maybe Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _openPlayStore();
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Open Google Play'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the app's Play Store listing. Falls back to web URL if Play Store
  /// app is not available.
  Future<void> _openPlayStore() async {
    final uri = Uri.parse(AppConstants.playStoreUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=${AppConstants.packageId}',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.inAppWebView);
        }
      }
    } catch (e) {
      debugPrint('[InAppUpdate] Failed to open Play Store: $e');
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
        duration: const Duration(days: 1),
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
