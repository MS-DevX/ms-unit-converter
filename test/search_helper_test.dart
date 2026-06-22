import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/utils/search_helper.dart';

void main() {
  group('SearchHelper.search()', () {
    test('empty query returns empty list', () {
      expect(SearchHelper.search(''), isEmpty);
    });

    test('blank query returns empty list', () {
      expect(SearchHelper.search('   '), isEmpty);
    });

    test('matches category displayName', () {
      final results = SearchHelper.search('Length');
      expect(results, contains(UnitCategory.length));
    });

    test('matches category description', () {
      final results = SearchHelper.search('shoe sizing');
      expect(results, contains(UnitCategory.shoeSize));
    });

    test('matches unit name', () {
      final results = SearchHelper.search('Meter');
      expect(results, contains(UnitCategory.length));
      expect(results, contains(UnitCategory.area));
    });

    test('matches unit symbol', () {
      final results = SearchHelper.search('km');
      expect(results, contains(UnitCategory.length));
    });

    test('case insensitive', () {
      final results = SearchHelper.search('pressure');
      expect(results, contains(UnitCategory.pressure));
      final upper = SearchHelper.search('PRESSURE');
      expect(upper, contains(UnitCategory.pressure));
    });

    test('common term "fuel" matches Fuel Economy', () {
      final results = SearchHelper.search('fuel');
      expect(results, contains(UnitCategory.fuelEconomy));
    });

    test('common term "size" matches Shoe Size and Clothing Size', () {
      final results = SearchHelper.search('size');
      expect(results, contains(UnitCategory.shoeSize));
      expect(results, contains(UnitCategory.clothingSize));
    });

    test('common term "binary" matches Number Base', () {
      final results = SearchHelper.search('binary');
      expect(results, contains(UnitCategory.numberBase));
    });

    test('common term "pixels" matches Typography', () {
      final results = SearchHelper.search('pixels');
      expect(results, contains(UnitCategory.typography));
    });

    test('partial match at start of word', () {
      final results = SearchHelper.search('angl');
      expect(results, contains(UnitCategory.angle));
    });

    test('no match returns empty list', () {
      final results = SearchHelper.search('zzzzzzz');
      expect(results, isEmpty);
    });

    test('respects custom categories list', () {
      final results = SearchHelper.search(
        'length',
        categories: [UnitCategory.weight, UnitCategory.temperature],
      );
      expect(results, isEmpty);
    });

    test('custom list with match', () {
      final results = SearchHelper.search(
        'weight',
        categories: [UnitCategory.weight, UnitCategory.temperature],
      );
      expect(results, hasLength(1));
      expect(results.first, UnitCategory.weight);
    });
  });

  group('SearchHelper.matchesCategory()', () {
    test('returns true for matching name', () {
      expect(
        SearchHelper.matchesCategory(UnitCategory.volume, 'volume'),
        isTrue,
      );
    });

    test('returns false for non-matching', () {
      expect(
        SearchHelper.matchesCategory(UnitCategory.volume, 'length'),
        isFalse,
      );
    });
  });
}
