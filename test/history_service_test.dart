import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/models/history_entry.dart';
import 'package:unit_converter/services/history_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  HistoryEntry makeEntry(String id) {
    return HistoryEntry(
      id: id,
      category: 'Length',
      inputValue: 10,
      fromUnit: 'Meter',
      toUnit: 'Kilometer',
      result: 0.01,
      timestamp: DateTime.parse('2026-05-31T10:00:00.000Z'),
    );
  }

  group('HistoryService', () {
    test('getEntries returns empty list initially', () async {
      final entries = await HistoryService.getEntries();
      expect(entries, isEmpty);
    });

    test('saveEntry and getEntries round-trip', () async {
      final entry = makeEntry('abc');
      await HistoryService.saveEntry(entry);
      final entries = await HistoryService.getEntries();
      expect(entries.length, 1);
      expect(entries.first, equals(entry));
    });

    test('entries are ordered newest first', () async {
      await HistoryService.saveEntry(makeEntry('first'));
      await HistoryService.saveEntry(makeEntry('second'));
      final entries = await HistoryService.getEntries();
      expect(entries.length, 2);
      expect(entries[0].id, 'second');
      expect(entries[1].id, 'first');
    });

    test('maxHistoryEntries is enforced', () async {
      for (int i = 0; i < AppConstants.maxHistoryEntries + 5; i++) {
        await HistoryService.saveEntry(makeEntry('id-$i'));
      }
      final entries = await HistoryService.getEntries();
      expect(entries.length, AppConstants.maxHistoryEntries);
    });

    test('clearAll removes entries', () async {
      await HistoryService.saveEntry(makeEntry('abc'));
      await HistoryService.clearAll();
      final entries = await HistoryService.getEntries();
      expect(entries, isEmpty);
    });

    test('clearAll preserves other preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('other_key', 'preserved');
      await HistoryService.saveEntry(makeEntry('abc'));
      await HistoryService.clearAll();
      expect(prefs.getString('other_key'), 'preserved');
    });

    test('corrupted JSON entry is skipped', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.historyStorageKey, [
        'not valid json',
      ]);
      final entries = await HistoryService.getEntries();
      expect(entries, isEmpty);
    });

    test('partially corrupted list still loads valid entries', () async {
      await HistoryService.saveEntry(makeEntry('valid1'));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(AppConstants.historyStorageKey)!;
      raw.add('corrupted garbage');
      await prefs.setStringList(AppConstants.historyStorageKey, raw);
      final entries = await HistoryService.getEntries();
      expect(entries.length, 1);
      expect(entries.first.id, 'valid1');
    });
  });
}
