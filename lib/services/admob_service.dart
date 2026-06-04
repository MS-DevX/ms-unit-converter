/// Service managing the App Open Ad lifecycle for MS Unit Converter.
///
/// Implemented as a singleton via [instance]. All ad failures degrade
/// gracefully — the app never blocks or crashes because of an ad.
///
/// ### When the ad shows
/// - Cold start (app launched fresh)
/// - Warm start after 4+ hours in background
/// - Never if [isPremium] is `true`
/// - Never if the ad failed to load (skip silently)
/// - Never if the cooldown (4 hours) has not elapsed
library;

import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Singleton service for the App Open Ad.
class AdmobService {
  AdmobService._();

  /// Shared singleton instance.
  static final AdmobService instance = AdmobService._();

  AppOpenAd? _appOpenAd;
  bool _isLoading = false;

  /// Whether a loaded ad is ready to show.
  bool get isAdReady => _appOpenAd != null;

  /// Loads a new App Open Ad and stores it in [_appOpenAd].
  ///
  /// Uses a [Completer] to bridge the callback-based [AppOpenAd.load] API,
  /// ensuring the returned Future does not complete until the ad has
  /// actually finished loading (or failed).
  ///
  /// Safe to call multiple times; only one load runs at a time.
  Future<void> loadAppOpenAd() async {
    if (_isLoading) return;
    _isLoading = true;

    _appOpenAd?.dispose();
    _appOpenAd = null;

    final completer = Completer<void>();

    try {
      AppOpenAd.load(
        adUnitId: AppConstants.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (AppOpenAd ad) {
            _appOpenAd = ad;
            _isLoading = false;
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _appOpenAd = null;
            _isLoading = false;
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (_) {
      _isLoading = false;
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  /// Shows the loaded App Open Ad if eligible.
  ///
  /// Eligibility checks (in order):
  /// 1. [isPremium] is `false`
  /// 2. Ad is loaded
  /// 3. Cooldown (4 hours) has elapsed since last show
  ///
  /// Returns `true` if the ad was shown, `false` otherwise.
  Future<bool> showAdIfEligible(bool isPremium) async {
    if (isPremium) return false;

    final ad = _appOpenAd;
    if (ad == null) return false;

    if (!(await _isCooldownElapsed())) return false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        _saveAdShownTimestamp();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );

    try {
      await ad.show();
      return true;
    } catch (_) {
      ad.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return false;
    }
  }

  /// Releases all ad resources.
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isLoading = false;
  }

  // ── Cooldown ────────────────────────────────────────────────────

  /// Returns `true` if the cooldown period has elapsed since the last
  /// ad was shown (or if no ad has ever been shown).
  Future<bool> _isCooldownElapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp =
          prefs.getInt(AppConstants.lastAdShownTimestampKey) ?? 0;
      if (lastTimestamp == 0) return true;
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      return elapsed >= AppConstants.adCooldownHours * 3600000;
    } catch (_) {
      return true;
    }
  }

  /// Persists the current timestamp so future launches respect cooldown.
  Future<void> _saveAdShownTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        AppConstants.lastAdShownTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Storage failure — ad simply shows again on next launch.
    }
  }
}
