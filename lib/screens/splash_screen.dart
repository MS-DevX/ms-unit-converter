/// Splash screen — brand impression + parallel ad/service init.
///
/// Always visible for at least 1500ms. During that time the App Open Ad
/// is loaded and premium status is checked. After the minimum duration:
/// - Premium users → skip ad, go straight to MainShell
/// - Free users with loaded ad + cooldown passed → show AppOpenAd, then MainShell
/// - Free users without loaded ad → skip, go straight to MainShell
library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../services/admob_service.dart';
import 'main_shell.dart';

/// Splash screen that runs for [AppConstants.splashDurationMs] (1500ms)
/// minimum and initialises the App Open Ad in the background.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _adReady = false;
  bool _minimumTimeElapsed = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _initAds();

    Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
      () {
        if (mounted) {
          setState(() => _minimumTimeElapsed = true);
        }
      },
    );
  }

  Future<void> _initAds() async {
    try {
      await MobileAds.instance.initialize();
      await AdmobService.instance.loadAppOpenAd();
    } catch (_) {
      // Non-mobile platform or ad failure — degrade gracefully.
    }
    if (mounted) {
      setState(() => _adReady = AdmobService.instance.isAdReady);
    }
  }

  /// Called once the minimum time has elapsed.
  void _onReady() {
    if (!mounted || _navigating) return;
    _navigating = true;

    final isPremium = context.read<SettingsProvider>().isPremium;

    if (isPremium || !_adReady) {
      _navigateToApp();
      return;
    }

    // Try to show the App Open Ad before navigating.
    AdmobService.instance.showAdIfEligible(isPremium).then((shown) {
      if (mounted) _navigateToApp();
    }).catchError((_) {
      if (mounted) _navigateToApp();
    });
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigate once minimum time elapsed.
    if (_minimumTimeElapsed && !_navigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onReady());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon.png',
                width: 80,
                height: 80,
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE6EDF3),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'by MS DevX',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8B949E),
              ),
            ),
            SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
