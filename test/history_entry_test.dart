import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/history_entry.dart';

void main() {
  group('HistoryEntry', () {
    const timestamp = '2026-05-31T10:00:00.000Z';

    final entry = HistoryEntry(
      id: 'abc123',
      category: 'Length',
      inputValue: 10.0,
      fromUnit: 'Meter',
      toUnit: 'Kilometer',
      result: 0.01,
      timestamp: DateTime.parse(timestamp),
    );

    test('toJson() produces correct map', () {
      final json = entry.toJson();
      expect(json['id'], 'abc123');
      expect(json['category'], 'Length');
      expect(json['inputValue'], 10.0);
      expect(json['fromUnit'], 'Meter');
      expect(json['toUnit'], 'Kilometer');
      expect(json['result'], 0.01);
      expect(json['timestamp'], timestamp);
    });

    test('fromJson() restores identical entry', () {
      final json = entry.toJson();
      final restored = HistoryEntry.fromJson(json);
      expect(restored, equals(entry));
      expect(restored.hashCode, equals(entry.hashCode));
    });

    test('fromJson() handles int values as double', () {
      final json = <String, dynamic>{
        'id': 'int-test',
        'category': 'Weight',
        'inputValue': 5,
        'fromUnit': 'kg',
        'toUnit': 'lb',
        'result': 11,
        'timestamp': timestamp,
      };
      final restored = HistoryEntry.fromJson(json);
      expect(restored.inputValue, isA<double>());
      expect(restored.inputValue, 5.0);
      expect(restored.result, 11.0);
    });

    test('toString() format', () {
      final str = entry.toString();
      expect(str, contains('abc123'));
      expect(str, contains('Length'));
      expect(str, contains('10.0'));
      expect(str, contains('Meter'));
      expect(str, contains('Kilometer'));
      expect(str, contains('0.01'));
      expect(str, contains(timestamp));
    });

    test('copyWith()', () {
      final modified = entry.copyWith(id: 'new-id', result: 1.0);
      expect(modified.id, 'new-id');
      expect(modified.result, 1.0);
      expect(modified.category, 'Length');
    });

    test('equality', () {
      final same = HistoryEntry(
        id: 'abc123',
        category: 'Length',
        inputValue: 10.0,
        fromUnit: 'Meter',
        toUnit: 'Kilometer',
        result: 0.01,
        timestamp: DateTime.parse(timestamp),
      );
      expect(entry, equals(same));
    });
  });
}
