
/// Bakery color palette for Melina Bakes.
///
/// Warm, inviting colors inspired by fresh bread, amber honey,
/// and rich chocolate. Designed for accessibility (WCAG 2.1 AA).
library;

import 'package:flutter/material.dart';

/// Primary brand colors.
abstract final class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD4A373);
  static const Color primaryDark = Color(0xFFB5835A);
  static const Color primaryLight = Color(0xFFF3D5B5);
  static const Color primaryContainer = Color(0xFFFFF3E0);

  static const Color secondary = Color(0xFF5D4037);
  static const Color secondaryContainer = Color(0xFFEFEBE9);

  static const Color cream = Color(0xFFFAEDCD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkElevated = Color(0xFF2C2C2C);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  static const Color onLightHigh = Color(0xFF1A1A1A);
  static const Color onLightMedium = Color(0xFF616161);
  static const Color onLightLow = Color(0xFF9E9E9E);
  static const Color onDarkHigh = Color(0xFFFFFFFF);
  static const Color onDarkMedium = Color(0xFFB0B0B0);
  static const Color disabled = Color(0xFFBDBDBD);

  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
}
