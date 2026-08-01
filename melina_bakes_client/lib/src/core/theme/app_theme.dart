
/// Material 3 theme configuration for Melina Bakes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

ThemeData createLightTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.secondary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.secondary,
    surface: AppColors.white,
    onSurface: AppColors.onLightHigh,
    surfaceContainerHighest: AppColors.surfaceLight,
    onSurfaceVariant: AppColors.onLightMedium,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.border,
    shadow: Colors.black.withOpacity(0.1),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    scaffoldBackgroundColor: AppColors.cream,
    canvasColor: AppColors.white,
    textTheme: _textTheme(cs.onSurface),
    appBarTheme: _appBarTheme(cs),
    cardTheme: _cardTheme(),
    elevatedButtonTheme: _elevatedBtn(cs),
    filledButtonTheme: _filledBtn(cs),
    outlinedButtonTheme: _outlinedBtn(cs),
    textButtonTheme: _textBtn(cs),
    inputDecorationTheme: _inputTheme(cs),
    chipTheme: _chipTheme(cs),
    bottomNavigationBarTheme: _bottomNav(cs),
    navigationRailTheme: _navRail(cs),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    snackBarTheme: _snackBar(cs),
    dialogTheme: _dialog(),
    tooltipTheme: _tooltip(),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

ThemeData createDarkTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onLightHigh,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.primaryLight,
    onSecondary: AppColors.onLightHigh,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.primaryLight,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onDarkHigh,
    surfaceContainerHighest: AppColors.surfaceDarkElevated,
    onSurfaceVariant: AppColors.onDarkMedium,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.borderDark,
    shadow: Colors.black.withOpacity(0.3),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    canvasColor: AppColors.surfaceDarkElevated,
    textTheme: _textTheme(cs.onSurface),
    appBarTheme: _appBarTheme(cs),
    cardTheme: _cardTheme(),
    elevatedButtonTheme: _elevatedBtn(cs),
    filledButtonTheme: _filledBtn(cs),
    outlinedButtonTheme: _outlinedBtn(cs),
    textButtonTheme: _textBtn(cs),
    inputDecorationTheme: _inputTheme(cs),
    chipTheme: _chipTheme(cs),
    bottomNavigationBarTheme: _bottomNav(cs),
    navigationRailTheme: _navRail(cs),
    dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 1, space: 1),
    snackBarTheme: _snackBar(cs),
    dialogTheme: _dialog(),
    tooltipTheme: _tooltip(),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

TextTheme _textTheme(Color c) => TextTheme(
  displayLarge: AppTypography.displayLarge(color: c),
  displayMedium: AppTypography.displayMedium(color: c),
  displaySmall: AppTypography.displaySmall(color: c),
  headlineLarge: AppTypography.headlineLarge(color: c),
  headlineMedium: AppTypography.headlineMedium(color: c),
  headlineSmall: AppTypography.headlineSmall(color: c),
  titleLarge: AppTypography.titleLarge(color: c),
  titleMedium: AppTypography.titleMedium(color: c),
  titleSmall: AppTypography.titleSmall(color: c),
  bodyLarge: AppTypography.bodyLarge(color: c),
  bodyMedium: AppTypography.bodyMedium(color: c),
  bodySmall: AppTypography.bodySmall(color: c),
  labelLarge: AppTypography.labelLarge(color: c),
  labelMedium: AppTypography.labelMedium(color: c),
  labelSmall: AppTypography.labelSmall(color: c),
);

AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
  elevation: 0, scrolledUnderElevation: 1, centerTitle: false,
  backgroundColor: cs.surface, foregroundColor: cs.onSurface,
  titleTextStyle: AppTypography.titleLarge(color: cs.onSurface),
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
);

CardTheme _cardTheme() => CardTheme(
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
  clipBehavior: Clip.antiAlias, margin: const EdgeInsets.all(0),
);

ElevatedButtonThemeData _elevatedBtn(ColorScheme cs) => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTypography.labelLarge(color: cs.onPrimary),
  ),
);

FilledButtonThemeData _filledBtn(ColorScheme cs) => FilledButtonThemeData(
  style: FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTypography.labelLarge(color: cs.onPrimary),
  ),
);

OutlinedButtonThemeData _outlinedBtn(ColorScheme cs) => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide(color: cs.outline),
    textStyle: AppTypography.labelLarge(color: cs.primary),
  ),
);

TextButtonThemeData _textBtn(ColorScheme cs) => TextButtonThemeData(
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTypography.labelLarge(color: cs.primary),
  ),
);

InputDecorationTheme _inputTheme(ColorScheme cs) => InputDecorationTheme(
  filled: true, fillColor: cs.surfaceContainerHighest,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 2)),
  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.error, width: 1)),
  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.error, width: 2)),
  hintStyle: AppTypography.bodyMedium(color: cs.onSurfaceVariant),
  labelStyle: AppTypography.bodyMedium(color: cs.onSurfaceVariant),
  errorStyle: AppTypography.bodySmall(color: cs.error),
);

ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
  backgroundColor: cs.surfaceContainerHighest, selectedColor: cs.primaryContainer,
  labelStyle: AppTypography.labelMedium(color: cs.onSurface),
  secondaryLabelStyle: AppTypography.labelMedium(color: cs.onPrimaryContainer),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

BottomNavigationBarThemeData _bottomNav(ColorScheme cs) => BottomNavigationBarThemeData(
  backgroundColor: cs.surface, selectedItemColor: cs.primary, unselectedItemColor: cs.onSurfaceVariant,
  type: BottomNavigationBarType.fixed, elevation: 2,
  showSelectedLabels: true, showUnselectedLabels: true,
  selectedLabelStyle: AppTypography.labelSmall(color: cs.primary),
  unselectedLabelStyle: AppTypography.labelSmall(color: cs.onSurfaceVariant),
);

NavigationRailThemeData _navRail(ColorScheme cs) => NavigationRailThemeData(
  backgroundColor: cs.surface,
  selectedIconTheme: IconThemeData(color: cs.primary, size: 24),
  unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 24),
  selectedLabelTextStyle: AppTypography.labelMedium(color: cs.primary),
  unselectedLabelTextStyle: AppTypography.labelMedium(color: cs.onSurfaceVariant),
  indicatorColor: cs.primaryContainer,
  indicatorShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
);

SnackBarThemeData _snackBar(ColorScheme cs) => SnackBarThemeData(
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  contentTextStyle: AppTypography.bodyMedium(color: cs.onInverseSurface),
  actionTextColor: cs.primary, backgroundColor: cs.inverseSurface,
);

DialogTheme _dialog() => DialogTheme(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4,
);

TooltipThemeData _tooltip() => TooltipThemeData(
  decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
  textStyle: AppTypography.bodySmall(color: AppColors.white),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  waitDuration: const Duration(milliseconds: 500),
  showDuration: const Duration(seconds: 3),
);
