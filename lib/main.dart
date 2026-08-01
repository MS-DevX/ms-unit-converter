library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'database/database_service.dart';
import 'providers/collections_provider.dart';
import 'providers/converter_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/custom_converter_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/history_provider.dart';
import 'providers/home_layout_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/pinned_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/usage_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Android 15/16 edge-to-edge system UI layout
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize the SQLite database before the widget tree is built.
  // This ensures all repositories are ready before providers access them.
  // The splash screen runs in parallel with ad loading; the DB is typically
  // ready within the 1500 ms splash minimum.
  await DatabaseService.instance.initialize();

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
  final UsageProvider _usage = UsageProvider();
  final CollectionsProvider _collections = CollectionsProvider();
  final PinnedProvider _pinned = PinnedProvider();
  final NotesProvider _notes = NotesProvider();
  final CustomConverterProvider _customConverters = CustomConverterProvider();
  final HomeLayoutProvider _homeLayout = HomeLayoutProvider();

  @override
  void initState() {
    super.initState();
    _settings.loadSettings();
    _history.loadHistory();
    _favorites.loadFavorites();
    _usage.loadUsage();
    _collections.loadCollections();
    _pinned.loadPinned();
    _notes.loadNotes();
    _customConverters.load();
    _homeLayout.load();
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
        ChangeNotifierProvider<UsageProvider>.value(value: _usage),
        ChangeNotifierProvider<CollectionsProvider>.value(value: _collections),
        ChangeNotifierProvider<PinnedProvider>.value(value: _pinned),
        ChangeNotifierProvider<NotesProvider>.value(value: _notes),
        ChangeNotifierProvider<CustomConverterProvider>.value(
            value: _customConverters),
        ChangeNotifierProvider<HomeLayoutProvider>.value(
            value: _homeLayout),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final lightTheme = AppTheme.buildLight(lightDynamic);
              final darkTheme = AppTheme.buildDark(darkDynamic);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Unit Converter',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: settings.themeMode,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
