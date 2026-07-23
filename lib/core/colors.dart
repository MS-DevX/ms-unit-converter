import 'package:flutter/material.dart';

/// Google Stitch Material Design 3 Design Tokens for MS Unit Converter.
class AppColors {
  AppColors._();

  // Core Material 3 Dark Palette (Stitch Specification)
  static const Color background = Color(0xFF0B1220);
  static const Color surface = Color(0xFF141D2E);
  static const Color surfaceContainerLowest = Color(0xFF0B0E15);
  static const Color surfaceContainerLow = Color(0xFF191B22);
  static const Color surfaceContainer = Color(0xFF1D1F27);
  static const Color surfaceContainerHigh = Color(0xFF272A31);
  static const Color surfaceContainerHighest = Color(0xFF32353C);
  static const Color surfaceVariant = Color(0xFF32353C);
  static const Color customCard = Color(0xFF1A2438);
  static const Color card = customCard;

  // Primary Tokens
  static const Color primary = Color(0xFF4F8CFF);
  static const Color primaryContainer = Color(0xFF1A2438);
  static const Color onPrimary = Color(0xFF002D6C);
  static const Color onPrimaryContainer = Color(0xFF00275F);
  static const Color primaryDark = Color(0xFF004398);

  // Secondary Tokens
  static const Color secondary = Color(0xFFBCC6E1);
  static const Color secondaryContainer = Color(0xFF3F495F);
  static const Color onSecondary = Color(0xFF263045);
  static const Color onSecondaryContainer = Color(0xFFAEB8D2);

  // Tertiary Tokens
  static const Color tertiary = Color(0xFFFFB77B);
  static const Color tertiaryContainer = Color(0xFFD87802);
  static const Color onTertiary = Color(0xFF4D2700);
  static const Color onTertiaryContainer = Color(0xFF432100);

  // Error & Status Tokens
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color danger = error;
  static const Color success = Color(0xFF22C55E);
  static const Color warning = tertiary;

  // Surface Text & Outlines
  static const Color onSurface = Color(0xFFE1E2EC);
  static const Color onSurfaceVariant = Color(0xFFC2C6D6);
  static const Color outline = Color(0xFF8C909F);
  static const Color outlineVariant = Color(0xFF424753);
  static const Color divider = outlineVariant;

  // Typography Text Aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;

  // Light Theme Fallbacks
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = outlineVariant;
  static const Color inputBorderLight = Color(0xFFCBD5E1);
  static const Color inputBorderDark = outlineVariant;
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = outlineVariant;

  // Category Accent Icons
  static const Color lengthIcon = primary;
  static const Color weightIcon = tertiary;
  static const Color tempIcon = error;
  static const Color areaIcon = Color(0xFFA855F7);
  static const Color volumeIcon = Color(0xFFF97316);
  static const Color speedIcon = Color(0xFF06B6D4);
  static const Color dataIcon = Color(0xFFEC4899);
  static const Color timeIcon = Color(0xFF6366F1);
  static const Color angleIcon = Color(0xFF14B8A6);
  static const Color energyIcon = Color(0xFFF59E0B);
  static const Color powerIcon = Color(0xFF8B5CF6);
  static const Color pressureIcon = Color(0xFF0EA5E9);
}
