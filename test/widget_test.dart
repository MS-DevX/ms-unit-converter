import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:unit_converter/core/theme.dart';
import 'package:unit_converter/providers/converter_provider.dart';
import 'package:unit_converter/providers/favorites_provider.dart';
import 'package:unit_converter/providers/history_provider.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/providers/usage_provider.dart';
import 'package:unit_converter/screens/converter_screen.dart';

/// Smoke test: the converter screen mounts without crashing and the
/// core UI elements render correctly.
void main() {
  testWidgets('ConverterScreen smoke test — mounts without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ConverterProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => UsageProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const ConverterScreen(),
        ),
      ),
    );

    // The AppBar title should show the default category (Length).
    expect(find.text('Length'), findsOneWidget);

    // The input bar has a numeric text field.
    expect(find.byType(TextField), findsOneWidget);

    // The swap button is rendered.
    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);

    // Source unit selector shows Meter.
    expect(find.text('Meter'), findsOneWidget);
  });
}
