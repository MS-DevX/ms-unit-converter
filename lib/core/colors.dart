import 'package:flutter/material.dart';

/// Centralized color system for MS Unit Converter app (Material 3 2026 Dark Slate Palette).
class AppColors {
  AppColors._();

  // Core Slate Dark Theme Palette
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color surface = Color(0xFF162033);
  static const Color divider = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)

  // Accent Colors
  static const Color primary = Color(0xFF4F8CFF);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x66FFFFFF); // 40% white

  // Legacy & Compatibility Mapping
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = background;

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = card;

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)

  static const Color inputBorderLight = Color(0xFFCBD5E1);
  static const Color inputBorderDark = Color(0xFF475569);

  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = divider;

  // Category Icon Colors (Neutral Slate Card + Vibrant Material Icon)
  static const Color lengthIcon = Color(0xFF4F8CFF);
  static const Color weightIcon = Color(0xFF22C55E);
  static const Color tempIcon = Color(0xFFEF4444);
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
