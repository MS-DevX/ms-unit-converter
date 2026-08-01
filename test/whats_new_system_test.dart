import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/data/release_notes_data.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/services/app_update_service.dart';
import 'package:unit_converter/widgets/whats_new_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("What's New System — Data Model & Registry Tests", () {
    test('allReleaseNotes registry contains valid v2.4.0 release notes', () {
      expect(allReleaseNotes, isNotEmpty);
      final notes = getLatestReleaseNotes();
      expect(notes, isNotNull);
      expect(notes!.version, equals('2.4.0+8'));
      expect(notes.displayVersion, equals('2.4.0'));
      expect(notes.title, equals("What's New"));
      expect(notes.subtitle, equals('Version 2.4.0'));
      expect(notes.sections.length, equals(5));

      // Verify all 5 sections exist
      final sectionTitles = notes.sections.map((s) => s.title).toList();
      expect(sectionTitles, contains('Smarter Search'));
      expect(sectionTitles, contains('Expanded Knowledge'));
      expect(sectionTitles, contains('Curated Collections'));
      expect(sectionTitles, contains('Performance Improvements'));
      expect(sectionTitles, contains('Reliability Improvements'));
    });

    test('getReleaseNotesForVersion matches version string correctly', () {
      final notes = getReleaseNotesForVersion('2.4.0+8');
      expect(notes, isNotNull);
      expect(notes!.version, equals('2.4.0+8'));

      final notesDisplay = getReleaseNotesForVersion('2.4.0');
      expect(notesDisplay, isNotNull);
      expect(notesDisplay!.displayVersion, equals('2.4.0'));
    });
  });

  group("What's New System — Widget Tests", () {
    testWidgets('WhatsNewDialog renders title, sections, items, and action buttons',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final settingsProvider = SettingsProvider();

      bool dismissed = false;

      final releaseNotes = getLatestReleaseNotes()!;

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => WhatsNewDialog(
                        releaseNotes: releaseNotes,
                        onDismiss: () {
                          dismissed = true;
                        },
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap button to pop dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify Dialog header
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Version 2.4.0'), findsOneWidget);
      expect(find.text('🚀'), findsOneWidget);

      // Verify Section Headers
      expect(find.text('Smarter Search'), findsOneWidget);
      expect(find.text('Expanded Knowledge'), findsOneWidget);
      expect(find.text('Curated Collections'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Tap 'Got it' primary button
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text("What's New"), findsNothing);
    });

    testWidgets('Fresh install initializes last_seen_version without showing dialog',
        (WidgetTester tester) async {
      AppUpdateService.instance.resetCheckedState();
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'Unit Converter',
        packageName: 'com.msdevx.unitconverter',
        version: '2.4.0',
        buildNumber: '8',
        buildSignature: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                AppUpdateService.instance.checkAndShowWhatsNew(context);
                return const Text('Home Screen');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is NOT displayed on fresh install
      expect(find.text("What's New"), findsNothing);

      // Verify SharedPreferences has last_seen_version set
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.keyLastSeenVersion), isNotNull);
      expect(prefs.getString(AppConstants.keyLastSeenVersion), equals('2.4.0+8'));
    });

    testWidgets('App update from older version pops WhatsNewDialog automatically',
        (WidgetTester tester) async {
      AppUpdateService.instance.resetCheckedState();
      SharedPreferences.setMockInitialValues({
        AppConstants.keyLastSeenVersion: '2.3.0+7',
      });
      PackageInfo.setMockInitialValues(
        appName: 'Unit Converter',
        packageName: 'com.msdevx.unitconverter',
        version: '2.4.0',
        buildNumber: '8',
        buildSignature: '',
      );

      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  AppUpdateService.instance.checkAndShowWhatsNew(context);
                  return const Text('Home Screen');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is displayed on version update
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Version 2.4.0'), findsOneWidget);
    });
  });
}
