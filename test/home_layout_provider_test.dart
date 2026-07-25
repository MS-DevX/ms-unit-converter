import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/providers/home_layout_provider.dart';
import 'package:unit_converter/services/home_layout_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeLayoutProvider Tests', () {
    test('load() populates default sections when storage is empty', () async {
      final provider = HomeLayoutProvider();
      await provider.load();

      expect(provider.sections.length, equals(HomeLayoutService.defaultSections.length));
      expect(provider.sections.first.id, equals('insights'));
    });

    test('toggleSection() updates isVisible and notifies listeners', () async {
      final provider = HomeLayoutProvider();
      await provider.load();

      final initialVisibility = provider.sections.first.isVisible;
      await provider.toggleSection('insights');

      expect(provider.sections.first.isVisible, equals(!initialVisibility));
    });

    test('reorder() changes section positions', () async {
      final provider = HomeLayoutProvider();
      await provider.load();

      final firstId = provider.sections[0].id;
      final secondId = provider.sections[1].id;

      await provider.reorder(0, 2);

      expect(provider.sections[0].id, equals(secondId));
      expect(provider.sections[1].id, equals(firstId));
    });

    test('resetToDefault() restores original sections', () async {
      final provider = HomeLayoutProvider();
      await provider.load();

      await provider.toggleSection('insights');
      await provider.reorder(0, 3);

      await provider.resetToDefault();

      expect(provider.sections.first.id, equals('insights'));
      expect(provider.sections.first.isVisible, isTrue);
    });
  });
}
