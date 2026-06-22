import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/services/iap_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IapService', () {
    test('isPurchased returns false when no premium stored', () async {
      final purchased = await IapService.instance.isPurchased();
      expect(purchased, false);
    });

    test('isPurchased returns true when premium is stored', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.premiumStorageKey, true);

      final purchased = await IapService.instance.isPurchased();
      expect(purchased, true);
    });

    test('isPurchased returns false when premium stored as false', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.premiumStorageKey, false);

      final purchased = await IapService.instance.isPurchased();
      expect(purchased, false);
    });
  });
}
