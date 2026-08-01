import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/responsive_helper.dart';
import 'package:unit_converter/widgets/stitch_bottom_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android 15/16 Edge-to-Edge Compatibility Tests', () {
    test('SystemUiMode edgeToEdge sets up without exception', () {
      expect(
        () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
        returnsNormally,
      );
    });

    testWidgets('ResponsiveHelper resolves compact breakpoint safely',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isCompact(context), isTrue);
                expect(
                  ResponsiveHelper.sizeClassOf(context),
                  equals(ScreenSizeClass.compact),
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('StitchBottomNav renders safely with bottom view padding insets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34, top: 48),
              viewPadding: EdgeInsets.only(bottom: 34, top: 48),
            ),
            child: Scaffold(
              bottomNavigationBar: StitchBottomNav(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  StitchNavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  StitchNavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify bottom nav renders without clipping or overflow
      expect(find.byType(StitchBottomNav), findsOneWidget);
    });
  });
}
