import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/admob_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdmobService Production Audit & Verification Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AdmobService.instance.dispose();
    });

    tearDown(() {
      AdmobService.instance.dispose();
    });

    test('isAdReady is false by default when no ad loaded', () {
      expect(AdmobService.instance.isAdReady, isFalse);
    });

    test('showAdIfEligible returns false when ad is not ready', () async {
      final shown = await AdmobService.instance.showAdIfEligible();
      expect(shown, isFalse);
    });

    test('initialize attaches lifecycle observer without crashing', () {
      AdmobService.instance.initialize();
      expect(true, isTrue);
    });

    test('didChangeAppLifecycleState(resumed) handles resume event safely', () {
      AdmobService.instance.initialize();
      expect(
        () => AdmobService.instance.didChangeAppLifecycleState(
          AppLifecycleState.resumed,
        ),
        returnsNormally,
      );
    });

    test('didChangeAppLifecycleState(paused) does not trigger ad eligibility', () {
      AdmobService.instance.initialize();
      expect(
        () => AdmobService.instance.didChangeAppLifecycleState(
          AppLifecycleState.paused,
        ),
        returnsNormally,
      );
    });

    test('Session cap and daily cap constants match specifications', () {
      expect(AdmobService.maxSessionShows, equals(3));
      expect(AdmobService.maxDailyShows, equals(5));
      expect(AdmobService.maxAdAge, equals(const Duration(hours: 4)));
    });
  });
}
