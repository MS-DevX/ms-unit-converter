library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Singleton service managing Google Mobile Ads App Open Ad lifecycle.
///
/// Features:
/// - Pure timestamp-based cooldown (5 minutes minimum between ad shows)
/// - App lifecycle state observer (resumes from background ONLY — no active foreground popups)
/// - 4-hour ad expiration check
/// - Session cap (max 3 shows per session)
/// - Daily cap (max 5 shows per calendar day)
/// - Automatic background preloading after dismissal or load failure
class AdmobService with WidgetsBindingObserver {
  AdmobService._();

  static final AdmobService instance = AdmobService._();

  AppOpenAd? _appOpenAd;
  DateTime? _adLoadTime;
  bool _isLoading = false;
  bool _isShowingAd = false;
  bool _isListeningLifecycle = false;

  /// Counter for ads shown in current app session (max 3).
  int _sessionShowCount = 0;

  /// Session cap constant.
  static const int maxSessionShows = 3;

  /// Daily cap constant.
  static const int maxDailyShows = 5;

  /// Maximum ad age before considered expired (Google standard: 4 hours).
  static const Duration maxAdAge = Duration(hours: 4);

  /// Key for daily ad count tracking in SharedPreferences.
  static const String _dailyAdCountKey = 'daily_ad_shown_count';
  static const String _dailyAdDateKey = 'daily_ad_shown_date';

  /// Whether an ad is loaded, unexpired, and ready to present.
  bool get isAdReady {
    if (_appOpenAd == null || _adLoadTime == null) return false;
    final age = DateTime.now().difference(_adLoadTime!);
    return age < maxAdAge;
  }

  /// Initializes lifecycle observation and loads the initial App Open Ad.
  void initialize() {
    if (!_isListeningLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _isListeningLifecycle = true;
      debugPrint('[AdmobService] Lifecycle observer attached');
    }
  }

  /// Loads an App Open Ad if not already loading or loaded.
  Future<void> loadAppOpenAd() async {
    if (_isLoading) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    // If ad is already loaded and not expired, skip reloading
    if (isAdReady) {
      debugPrint('[AdmobService] Ad already ready and valid — skip reload');
      return;
    }

    // Dispose old expired ad if any
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _adLoadTime = null;
    _isLoading = true;

    final completer = Completer<void>();

    try {
      AppOpenAd.load(
        adUnitId: AppConstants.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (AppOpenAd ad) {
            _appOpenAd = ad;
            _adLoadTime = DateTime.now();
            _isLoading = false;
            debugPrint(
              '[AdmobService] App Open Ad loaded successfully at $_adLoadTime',
            );
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _appOpenAd = null;
            _adLoadTime = null;
            _isLoading = false;
            debugPrint('[AdmobService] Failed to load App Open Ad: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      _appOpenAd = null;
      _adLoadTime = null;
      debugPrint('[AdmobService] Error loading App Open Ad: $e');
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  /// Shows the App Open Ad if all eligibility criteria are met.
  Future<bool> showAdIfEligible() async {
    if (_isShowingAd) {
      debugPrint('[AdmobService] Already showing an ad — skip');
      return false;
    }

    // 1. Check session cap
    if (_sessionShowCount >= maxSessionShows) {
      debugPrint(
        '[AdmobService] Session cap reached ($_sessionShowCount/$maxSessionShows) — skip',
      );
      return false;
    }

    // 2. Check daily cap
    if (!(await _isDailyCapEligible())) {
      debugPrint('[AdmobService] Daily cap reached ($maxDailyShows) — skip');
      return false;
    }

    // 3. Check ad readiness & expiration
    if (!isAdReady) {
      debugPrint('[AdmobService] Ad not ready or expired');
      if (_appOpenAd != null) {
        _appOpenAd?.dispose();
        _appOpenAd = null;
        _adLoadTime = null;
        loadAppOpenAd();
      }
      return false;
    }

    // 4. Check timestamp-based cooldown
    if (!(await _isCooldownElapsed())) {
      debugPrint('[AdmobService] Cooldown not elapsed (must be >= 5 mins)');
      return false;
    }

    final ad = _appOpenAd!;
    _isShowingAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        debugPrint('[AdmobService] App Open Ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        _adLoadTime = null;
        _isShowingAd = false;
        _sessionShowCount++;
        _saveAdShownTimestampAndIncrementDaily();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        debugPrint('[AdmobService] Failed to show App Open Ad: $error');
        ad.dispose();
        _appOpenAd = null;
        _adLoadTime = null;
        _isShowingAd = false;
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        debugPrint('[AdmobService] App Open Ad presented successfully');
      },
      onAdImpression: (AppOpenAd ad) {
        debugPrint('[AdmobService] App Open Ad impression recorded');
      },
    );

    try {
      await ad.show();
      return true;
    } catch (e) {
      debugPrint('[AdmobService] Error invoking ad.show(): $e');
      ad.dispose();
      _appOpenAd = null;
      _adLoadTime = null;
      _isShowingAd = false;
      loadAppOpenAd();
      return false;
    }
  }

  /// App lifecycle listener for foreground resume events.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        '[AdmobService] App resumed from background — checking ad eligibility',
      );
      showAdIfEligible();
    }
  }

  /// Clean up lifecycle observer and active ad.
  void dispose() {
    if (_isListeningLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _isListeningLifecycle = false;
    }
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _adLoadTime = null;
    _isLoading = false;
    _isShowingAd = false;
  }

  /// Checks if minimum 5-minute cooldown has elapsed using SharedPreferences timestamp.
  Future<bool> _isCooldownElapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp =
          prefs.getInt(AppConstants.lastAdShownTimestampKey) ?? 0;
      if (lastTimestamp == 0) return true;

      final elapsed = DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      final cooldownMs = AppConstants.adCooldownMinutes * 60000;
      return elapsed >= cooldownMs;
    } catch (_) {
      return true;
    }
  }

  /// Checks if daily show count cap (max 5 per calendar day) has not been exceeded.
  Future<bool> _isDailyCapEligible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDateStr = prefs.getString(_dailyAdDateKey) ?? '';

      if (lastDateStr != todayStr) {
        // Reset counter for new calendar day
        await prefs.setString(_dailyAdDateKey, todayStr);
        await prefs.setInt(_dailyAdCountKey, 0);
        return true;
      }

      final count = prefs.getInt(_dailyAdCountKey) ?? 0;
      return count < maxDailyShows;
    } catch (_) {
      return true;
    }
  }

  /// Saves current timestamp and increments daily count upon successful ad display.
  Future<void> _saveAdShownTimestampAndIncrementDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10);

      await prefs.setInt(
        AppConstants.lastAdShownTimestampKey,
        now.millisecondsSinceEpoch,
      );

      final lastDateStr = prefs.getString(_dailyAdDateKey) ?? '';
      int currentCount = 0;
      if (lastDateStr == todayStr) {
        currentCount = prefs.getInt(_dailyAdCountKey) ?? 0;
      } else {
        await prefs.setString(_dailyAdDateKey, todayStr);
      }
      await prefs.setInt(_dailyAdCountKey, currentCount + 1);
    } catch (_) {}
  }
}
