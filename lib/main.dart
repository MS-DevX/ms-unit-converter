/// App entry point, provider bootstrap, and navigation shell.
///
/// [main] performs one-time service initialization before the first
/// frame, then hands off to [MyApp] which owns the provider tree.
/// The splash screen ([SplashScreen]) handles App Open Ad loading
/// and a 1500ms brand impression before handing off to [MainShell].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/converter_provider.dart';
import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'services/iap_service.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IAP is only initialised on mobile platforms (Android / iOS).
  // On desktop (Windows, Linux, macOS) the native store implementation
  // is absent and would throw MissingPluginException.
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await IapService.instance.initialize();
  }

  runApp(const MyApp());
}

// ── Root widget ───────────────────────────────────────────────────────────────

/// Root [StatefulWidget] that owns all [ChangeNotifier] instances and
/// wires them into the widget tree via [MultiProvider].
///
/// Stateful so that providers are created once and persist for the app's
/// lifetime. [SettingsProvider.loadSettings] and
/// [HistoryProvider.loadHistory] are triggered in [initState] to begin
/// loading persisted data before the first frame renders.
class MyApp extends StatefulWidget {
  /// Creates [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Providers are owned here so they live for the full app lifetime.
  final SettingsProvider _settings = SettingsProvider();
  final ConverterProvider _converter = ConverterProvider();
  final HistoryProvider _history = HistoryProvider();

  @override
  void initState() {
    super.initState();
    // Load persisted settings and history without blocking the first frame.
    _settings.loadSettings();
    _history.loadHistory();

    // Dynamically unlock premium in the provider when purchases complete.
    IapService.instance.onPremiumUnlocked = () {
      _settings.setPremium(true);
    };
  }

  @override
  void dispose() {
    IapService.instance.onPremiumUnlocked = null;
    IapService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: _settings),
        ChangeNotifierProvider<ConverterProvider>.value(value: _converter),
        ChangeNotifierProvider<HistoryProvider>.value(value: _history),
      ],
      // Consumer here so themeMode updates re-render MaterialApp only.
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MS Unit Converter',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
