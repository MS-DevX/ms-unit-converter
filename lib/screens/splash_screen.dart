library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';

import '../core/constants.dart';
import '../services/admob_service.dart';
import '../services/in_app_update_service.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minimumTimeElapsed = false;
  bool _adReady = false;
  bool _adTimedOut = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _initAds();
    _checkUpdate();

    Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
      () {
        if (mounted) {
          setState(() => _minimumTimeElapsed = true);
        }
      },
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _adTimedOut = true);
      }
    });
  }

  Future<void> _initAds() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('[Splash] MobileAds initialized');
      await AdmobService.instance.loadAppOpenAd();
      debugPrint('[Splash] Ad load completed');
    } catch (e) {
      debugPrint('[Splash] Ad init error: $e');
    }
    if (mounted) {
      setState(() => _adReady = AdmobService.instance.isAdReady);
    }
  }

  Future<void> _checkUpdate() async {
    final info = await InAppUpdateService.instance.checkForUpdate();
    if (!mounted || info == null) {
      return;
    }
    if (info.updateAvailability != UpdateAvailability.updateAvailable ||
        !info.flexibleUpdateAllowed) {
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
          'A new version of MS Unit Converter is available. '
          'Would you like to download it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (!mounted || proceed != true) return;

    final result = await InAppUpdateService.instance.startFlexibleUpdate();
    if (result != AppUpdateResult.success) return;

    InAppUpdateService.instance.installUpdateListener.listen((status) {
      if (status == InstallStatus.downloaded && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Update Downloaded'),
            content: const Text(
              'The update has been downloaded. Restart to install it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  InAppUpdateService.instance.completeFlexibleUpdate();
                },
                child: const Text('Install'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _onReady() {
    if (!mounted || _navigating) return;
    _navigating = true;

    final ad = AdmobService.instance;

    if (!ad.isAdReady) {
      debugPrint('[Splash] No ad ready, navigating directly');
      _navigateToApp();
      return;
    }

    ad.showAdIfEligible().then((shown) {
      debugPrint('[Splash] Ad shown: $shown');
      if (mounted) _navigateToApp();
    }).catchError((e) {
      debugPrint('[Splash] Ad show error: $e');
      if (mounted) _navigateToApp();
    });
  }

  void _navigateToApp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    if (_minimumTimeElapsed && !_navigating) {
      if (_adReady || _adTimedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _onReady());
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icon.png', width: 80, height: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE6EDF3),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'by MS DevX',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8B949E),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
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
