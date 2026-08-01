import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/release_notes_data.dart';
import '../widgets/whats_new_dialog.dart';

/// Service responsible for managing version update detection and displaying
/// the one-time "What's New" release notes dialog after app updates.
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  bool _hasChecked = false;

  /// Resets checked flag (used for unit & widget tests).
  @visibleForTesting
  void resetCheckedState() {
    _hasChecked = false;
  }

  /// Checks if the app has been updated to a new version and presents the
  /// "What's New" dialog once per release.
  ///
  /// Safe to call on home screen mount; executes in post-frame callback and
  /// will never block app startup or database loading.
  Future<void> checkAndShowWhatsNew(BuildContext context) async {
    if (_hasChecked) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasChecked || !context.mounted) return;
      _hasChecked = true;

      try {
        final prefs = await SharedPreferences.getInstance();
        final packageInfo = await PackageInfo.fromPlatform();

        final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
        final lastSeenVersion = prefs.getString(AppConstants.keyLastSeenVersion);

        if (lastSeenVersion == null) {
          // Fresh install: silently initialize last_seen_version to current version
          // so onboarding is not interrupted with update release notes.
          await prefs.setString(AppConstants.keyLastSeenVersion, currentVersion);
          debugPrint('[AppUpdateService] Fresh install detected — set last_seen_version: $currentVersion');
          return;
        }

        if (lastSeenVersion != currentVersion) {
          final releaseNotes = getReleaseNotesForVersion(currentVersion) ??
              getLatestReleaseNotes();

          if (releaseNotes != null && context.mounted) {
            debugPrint('[AppUpdateService] Version update detected ($lastSeenVersion → $currentVersion) — displaying What\'s New');

            await showDialog(
              context: context,
              barrierDismissible: true,
              builder: (dialogContext) => WhatsNewDialog(
                releaseNotes: releaseNotes,
                onDismiss: () async {
                  await prefs.setString(
                    AppConstants.keyLastSeenVersion,
                    currentVersion,
                  );
                  debugPrint('[AppUpdateService] Saved last_seen_version: $currentVersion');
                },
              ),
            );
          }
        } else {
          debugPrint('[AppUpdateService] Already on current version ($currentVersion) — skipping What\'s New');
        }
      } catch (e) {
        debugPrint('[AppUpdateService] Error checking version updates: $e');
      }
    });
  }
}
