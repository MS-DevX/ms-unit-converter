library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/converter_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsProvider _settings = SettingsProvider();
  final ConverterProvider _converter = ConverterProvider();
  final CurrencyProvider _currency = CurrencyProvider();
  final HistoryProvider _history = HistoryProvider();
  final FavoritesProvider _favorites = FavoritesProvider();

  @override
  void initState() {
    super.initState();
    _settings.loadSettings();
    _history.loadHistory();
    _favorites.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: _settings),
        ChangeNotifierProvider<ConverterProvider>.value(value: _converter),
        ChangeNotifierProvider<CurrencyProvider>.value(value: _currency),
        ChangeNotifierProvider<HistoryProvider>.value(value: _history),
        ChangeNotifierProvider<FavoritesProvider>.value(value: _favorites),
      ],
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
