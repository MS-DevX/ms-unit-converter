import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/models/companion_result.dart';
import 'package:unit_converter/providers/custom_converter_provider.dart';
import 'package:unit_converter/providers/favorites_provider.dart';
import 'package:unit_converter/providers/history_provider.dart';
import 'package:unit_converter/providers/notes_provider.dart';
import 'package:unit_converter/providers/pinned_provider.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/providers/usage_provider.dart';
import 'package:unit_converter/screens/unit_companion_screen.dart';
import 'package:unit_converter/services/companion_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.instance.initialize();
  });

  tearDownAll(() async {
    await DatabaseService.instance.close();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CompanionSearchResult Model Tests', () {
    test('groupTitle returns appropriate group headers', () {
      expect(CompanionSearchResult.groupTitle(CompanionResultType.unit), contains('Units'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.category), contains('Categories'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.currency), contains('Currency'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.definition), contains('Definitions'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.formula), contains('Formulas'));
    });
  });

  group('CompanionSearchService Unit Tests', () {
    testWidgets('search returns matching units for meter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoritesProvider()..loadFavorites()),
            ChangeNotifierProvider(create: (_) => PinnedProvider()..loadPinned()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
            ChangeNotifierProvider(create: (_) => CustomConverterProvider()..load()),
            ChangeNotifierProvider(create: (_) => NotesProvider()..loadNotes()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final results = await CompanionSearchService.search(
                      context: context,
                      query: 'meter',
                    );
                    expect(results, isNotEmpty);
                    expect(results.any((r) => r.title.toLowerCase().contains('meter')), isTrue);

                    final intentResults = await CompanionSearchService.search(
                      context: context,
                      query: '10 ft to m',
                    );
                    expect(intentResults, isNotEmpty);
                    expect(intentResults.any((r) => r.type == CompanionResultType.intent), isTrue);

                    final guideResults = await CompanionSearchService.search(
                      context: context,
                      query: 'tv size',
                    );
                    expect(guideResults, isNotEmpty);
                    expect(guideResults.any((r) => r.type == CompanionResultType.guide), isTrue);
                  },
                  child: const Text('Search'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
    });
  });

  group('UnitCompanionScreen Widget Tests', () {
    testWidgets('renders header, search bar, and suggestion chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()..loadFavorites()),
            ChangeNotifierProvider(create: (_) => PinnedProvider()..loadPinned()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
            ChangeNotifierProvider(create: (_) => CustomConverterProvider()..load()),
            ChangeNotifierProvider(create: (_) => NotesProvider()..loadNotes()),
            ChangeNotifierProvider(create: (_) => UsageProvider()..loadUsage()),
          ],
          child: const MaterialApp(
            home: UnitCompanionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Unit Companion'), findsOneWidget);
      expect(find.text('100% Offline Knowledge & Discovery'), findsOneWidget);
      expect(find.text('Length'), findsWidgets);
      expect(find.text('Weight'), findsWidgets);
      expect(find.text('Temperature'), findsWidgets);
    });
  });
}
