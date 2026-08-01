import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/widgets/user_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('avatar_test_');
    for (final channelName in [
      'plugins.flutter.io/path_provider',
      'plugins.flutter.io/path_provider_linux',
      'plugins.flutter.io/path_provider_macos',
      'plugins.flutter.io/path_provider_ios',
      'plugins.flutter.io/path_provider_android',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channelName),
              (MethodCall methodCall) async {
        return tempDir.path;
      });
    }
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('User Avatar Resolution & Persistence Tests', () {
    test('setUserAvatarPath copies source image to permanent ApplicationDocumentsDirectory',
        () async {
      final settings = SettingsProvider();

      // Create a dummy source file simulating image_picker cache output
      final sourceFile = File('${tempDir.path}/temp_picker_image.jpg');
      await sourceFile.writeAsBytes([1, 2, 3, 4, 5, 6, 7, 8]);

      await settings.setUserAvatarPath(sourceFile.path);

      expect(settings.userAvatarPath, isNotEmpty);
      expect(settings.userAvatarPath, contains('profile'));
      expect(settings.userAvatarPath, isNot(equals(sourceFile.path)));

      final permanentFile = File(settings.userAvatarPath);
      expect(await permanentFile.exists(), isTrue);
      expect(await permanentFile.readAsBytes(), equals([1, 2, 3, 4, 5, 6, 7, 8]));

      // Verify path saved in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(SettingsProvider.userAvatarPathStorageKey),
        equals(settings.userAvatarPath),
      );
    });

    test('removeUserAvatar deletes permanent file and clears SharedPreferences', () async {
      final settings = SettingsProvider();

      final sourceFile = File('${tempDir.path}/temp_avatar.jpg');
      await sourceFile.writeAsBytes([9, 8, 7, 6]);

      await settings.setUserAvatarPath(sourceFile.path);
      final permPath = settings.userAvatarPath;
      expect(await File(permPath).exists(), isTrue);

      await settings.removeUserAvatar();

      expect(settings.userAvatarPath, isEmpty);
      expect(await File(permPath).exists(), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(SettingsProvider.userAvatarPathStorageKey),
        isNull,
      );
    });

    testWidgets('UserAvatar falls back to initials when file is missing or deleted',
        (WidgetTester tester) async {
      final settings = SettingsProvider();
      await settings.setUserName('Shahzad Dev');
      settings.userAvatarPath = '${tempDir.path}/missing_avatar.jpg';

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: const MaterialApp(
            home: Scaffold(
              body: UserAvatar(size: 64),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify fallback initials 'SD' are rendered
      expect(find.text('SD'), findsOneWidget);
    });

    testWidgets('UserAvatar renders UserAvatar initials when no avatar path',
        (WidgetTester tester) async {
      final settings = SettingsProvider();
      await settings.setUserName('Jane Doe');

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: const MaterialApp(
            home: Scaffold(
              body: UserAvatar(size: 64),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('JD'), findsOneWidget);
    });
  });
}
