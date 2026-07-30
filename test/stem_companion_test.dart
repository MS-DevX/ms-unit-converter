import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/models/companion_result.dart';
import 'package:unit_converter/providers/custom_converter_provider.dart';
import 'package:unit_converter/providers/favorites_provider.dart';
import 'package:unit_converter/providers/history_provider.dart';
import 'package:unit_converter/providers/notes_provider.dart';
import 'package:unit_converter/providers/pinned_provider.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/providers/usage_provider.dart';
import 'package:unit_converter/screens/stem_companion_screen.dart';
import 'package:unit_converter/services/companion_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CompanionSearchResult Model Tests', () {
    test('groupTitle returns appropriate group headers for STEM types', () {
      expect(CompanionSearchResult.groupTitle(CompanionResultType.unit), contains('Units'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.category), contains('Categories'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.currency), contains('Currency'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.definition), contains('Definitions'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.formula), contains('Formulas'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.physics), contains('Physics'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.chemistry), contains('Chemistry'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.mathematics), contains('Mathematics'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.constant), contains('Scientific Constants'));
      expect(CompanionSearchResult.groupTitle(CompanionResultType.bookmark), contains('Bookmarks'));
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

                    final mathResults = await CompanionSearchService.search(
                      context: context,
                      query: 'mathematics',
                    );
                    expect(mathResults, isNotEmpty);

                    final physicsResults = await CompanionSearchService.search(
                      context: context,
                      query: 'physics',
                    );
                    expect(physicsResults, isNotEmpty);
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

  group('StemCompanionScreen Widget Tests', () {
    testWidgets('renders STEM header, search bar, and suggested quick topic chips', (WidgetTester tester) async {
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
            home: StemCompanionScreen(),
          ),
        ),
      );

      expect(find.text('STEM Companion'), findsOneWidget);
      expect(find.text('Search your offline STEM library.'), findsOneWidget);
      expect(find.text('100% Offline STEM Hub'), findsOneWidget);
      expect(find.text('Mathematics'), findsWidgets);
      expect(find.text('Physics'), findsWidgets);
      expect(find.text('Chemistry'), findsWidgets);

      // Scroll chip bar horizontally to expose Bookmarks chip
      await tester.drag(find.byType(ListView).first, const Offset(-1000, 0));
      await tester.pumpAndSettle();

      expect(find.text('Recently Viewed'), findsWidgets);
      expect(find.text('Bookmarks'), findsWidgets);
    });
  });
}
