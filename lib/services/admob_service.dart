library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class AdmobService {
  AdmobService._();

  static final AdmobService instance = AdmobService._();

  AppOpenAd? _appOpenAd;
  bool _isLoading = false;

  bool get isAdReady => _appOpenAd != null;

  Future<void> loadAppOpenAd() async {
    if (_isLoading) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
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
            debugPrint('[AdmobService] App Open Ad loaded');
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _appOpenAd = null;
            _isLoading = false;
            debugPrint('[AdmobService] Failed to load ad: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('[AdmobService] Error loading ad: $e');
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  Future<bool> showAdIfEligible() async {
    final ad = _appOpenAd;
    if (ad == null) {
      debugPrint('[AdmobService] No ad ready to show');
      return false;
    }

    if (!(await _isCooldownElapsed())) {
      debugPrint('[AdmobService] Ad cooldown not elapsed');
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        debugPrint('[AdmobService] Ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        _saveAdShownTimestamp();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        debugPrint('[AdmobService] Failed to show ad: $error');
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        debugPrint('[AdmobService] Ad showed successfully');
      },
      onAdImpression: (AppOpenAd ad) {
        debugPrint('[AdmobService] Ad impression recorded');
      },
    );

    try {
      await ad.show();
      return true;
    } catch (e) {
      debugPrint('[AdmobService] Error showing ad: $e');
      ad.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return false;
    }
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isLoading = false;
  }

  Future<bool> _isCooldownElapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp =
          prefs.getInt(AppConstants.lastAdShownTimestampKey) ?? 0;
      if (lastTimestamp == 0) return true;
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      return elapsed >= AppConstants.adCooldownMinutes * 60000;
    } catch (_) {
      return true;
    }
  }

  Future<void> _saveAdShownTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        AppConstants.lastAdShownTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
    }
  }
}
