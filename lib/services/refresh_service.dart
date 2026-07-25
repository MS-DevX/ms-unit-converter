/// Centralized RefreshService for handling global Pull-to-Refresh across the app.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/collections_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/custom_converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/home_layout_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/pinned_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/usage_provider.dart';

/// Outcome of a full app refresh.
class RefreshResult {
  final bool ratesUpdated;
  final bool isOffline;
  final bool isSuccess;

  const RefreshResult({
    required this.ratesUpdated,
    required this.isOffline,
    required this.isSuccess,
  });
}

/// Centralized manager that orchestrates concurrent data, rate, index, and UI refreshes.
class RefreshService {
  RefreshService._();

  /// Executes all app refresh tasks concurrently, enforces an 800ms minimum duration,
  /// and shows a Material 3 floating SnackBar with the refresh status.
  static Future<RefreshResult> refreshApp(
    BuildContext context, {
    bool showSnackBar = true,
  }) async {
    final startTime = DateTime.now();

    bool ratesUpdated = false;
    bool isOffline = false;

    // Concurrently execute all independent refresh tasks without stopping on single failure
    await Future.wait([
      // 1. Currency rates & currency list
      _safeTask(() async {
        try {
          final currencyProv = context.read<CurrencyProvider>();
          await currencyProv.refreshCurrencies();
          await currencyProv.refreshRates();
          ratesUpdated = !currencyProv.isOffline && !currencyProv.isUsingCached;
          isOffline = currencyProv.isOffline;
        } catch (e) {
          debugPrint('RefreshService: Currency refresh error: $e');
        }
      }),

      // 2. Conversion History
      _safeTask(() async {
        try {
          await context.read<HistoryProvider>().loadHistory();
        } catch (e) {
          debugPrint('RefreshService: History load error: $e');
        }
      }),

      // 3. Favorites
      _safeTask(() async {
        try {
          await context.read<FavoritesProvider>().loadFavorites();
        } catch (e) {
          debugPrint('RefreshService: Favorites load error: $e');
        }
      }),

      // 4. Pinned Categories
      _safeTask(() async {
        try {
          await context.read<PinnedProvider>().loadPinned();
        } catch (e) {
          debugPrint('RefreshService: Pinned load error: $e');
        }
      }),

      // 5. Usage Stats
      _safeTask(() async {
        try {
          await context.read<UsageProvider>().loadUsage();
        } catch (e) {
          debugPrint('RefreshService: Usage load error: $e');
        }
      }),

      // 6. User Notes
      _safeTask(() async {
        try {
          await context.read<NotesProvider>().loadNotes();
        } catch (e) {
          debugPrint('RefreshService: Notes load error: $e');
        }
      }),

      // 7. Custom Converters
      _safeTask(() async {
        try {
          await context.read<CustomConverterProvider>().load();
        } catch (e) {
          debugPrint('RefreshService: CustomConverter load error: $e');
        }
      }),

      // 8. Curated Collections
      _safeTask(() async {
        try {
          await context.read<CollectionsProvider>().loadCollections();
        } catch (e) {
          debugPrint('RefreshService: Collections load error: $e');
        }
      }),

      // 9. Home Layout
      _safeTask(() async {
        try {
          await context.read<HomeLayoutProvider>().load();
        } catch (e) {
          debugPrint('RefreshService: HomeLayout load error: $e');
        }
      }),

      // 10. User Settings
      _safeTask(() async {
        try {
          await context.read<SettingsProvider>().loadSettings();
        } catch (e) {
          debugPrint('RefreshService: Settings load error: $e');
        }
      }),
    ]);

    // Enforce minimum 800ms animation duration for polished Material 3 feel
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 800) {
      await Future.delayed(Duration(milliseconds: 800 - elapsed.inMilliseconds));
    }

    final result = RefreshResult(
      ratesUpdated: ratesUpdated,
      isOffline: isOffline,
      isSuccess: true,
    );

    if (showSnackBar && context.mounted) {
      final colorScheme = Theme.of(context).colorScheme;
      String message;
      IconData icon;

      if (ratesUpdated) {
        message = 'Exchange rates & local data updated.';
        icon = Icons.cloud_done_rounded;
      } else if (isOffline) {
        message = 'You\'re offline. Saved rates & local data refreshed.';
        icon = Icons.wifi_off_rounded;
      } else {
        message = 'Everything is up to date.';
        icon = Icons.check_circle_outline_rounded;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: colorScheme.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return result;
  }

  static Future<void> _safeTask(Future<void> Function() task) async {
    try {
      await task();
    } catch (e) {
      debugPrint('RefreshTask caught non-fatal exception: $e');
    }
  }
}
