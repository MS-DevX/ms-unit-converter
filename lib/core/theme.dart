import 'package:flutter/material.dart';
import 'colors.dart';

/// AppTheme — Google Stitch Material Design 3 Theme System for MS Unit Converter.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      onError: AppColors.onError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      // Stitch M3 Typography Specs
      textTheme: const TextTheme(
        // Display Large: 36px / 44px line height / bold
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          height: 44 / 36,
          letterSpacing: -0.72,
        ),

        // Headline Medium: 28px / 36px line height / semi-bold
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 36 / 28,
          letterSpacing: -0.3,
        ),

        // Title Medium: 22px / 28px line height / medium
        titleMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          height: 28 / 22,
        ),

        // Title Large (Compatibility)
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 28 / 22,
        ),

        // Body Large: 16px / 24px line height / regular
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 24 / 16,
        ),

        // Label Medium: 15px / 20px line height / medium
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          height: 20 / 15,
        ),

        // Caption Small (bodySmall): 13px / 16px line height / regular
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
          height: 16 / 13,
        ),

        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
          height: 14 / 11,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),

      // Material 3 Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.surface,
        elevation: 4,
        indicatorColor: AppColors.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.onSecondaryContainer, size: 24);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSecondaryContainer,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          );
        }),
      ),

      // Card Theme (16/20px rounded corners, Stitch customCard)
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.customCard,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.outline,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(0, 48),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}
