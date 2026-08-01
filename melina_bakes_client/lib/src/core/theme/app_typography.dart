
/// Typography system for Melina Bakes.
///
/// Uses Google Fonts (Playfair Display for headings,
/// Inter for body text) to create an elegant bakery aesthetic.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  AppTypography._();

  static TextStyle displayLarge({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 57, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.25, color: color);
  static TextStyle displayMedium({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 45, fontWeight: FontWeight.w400, height: 1.16, color: color);
  static TextStyle displaySmall({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w400, height: 1.22, color: color);

  static TextStyle headlineLarge({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w600, height: 1.25, color: color);
  static TextStyle headlineMedium({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600, height: 1.29, color: color);
  static TextStyle headlineSmall({required Color color}) => GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: color);

  static TextStyle titleLarge({required Color color}) => GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w500, height: 1.27, color: color);
  static TextStyle titleMedium({required Color color}) => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, letterSpacing: 0.15, color: color);
  static TextStyle titleSmall({required Color color}) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1, color: color);

  static TextStyle bodyLarge({required Color color}) => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5, color: color);
  static TextStyle bodyMedium({required Color color}) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25, color: color);
  static TextStyle bodySmall({required Color color}) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4, color: color);

  static TextStyle labelLarge({required Color color}) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1, color: color);
  static TextStyle labelMedium({required Color color}) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5, color: color);
  static TextStyle labelSmall({required Color color}) => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5, color: color);
}
