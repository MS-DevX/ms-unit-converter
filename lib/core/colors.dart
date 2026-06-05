import 'package:flutter/material.dart';

/// Centralized color system for MS Unit Converter app.
/// Provides both light and dark theme-ready color tokens.
class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF14B8A6);

  // Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0F172A);

  // Surfaces
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text colors
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // UI states
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Borders & chips
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  static const Color chipInactive = Color(0xFFE2E8F0);
  static const Color chipActive = Color(0xFF2563EB);

  // Divider
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF334155);

  // Currency converter
  static const Color currencyFrom = Color(0xFF059669);
  static const Color currencyTo = Color(0xFFD97706);
}
