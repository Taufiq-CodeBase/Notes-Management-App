import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const double _radius = 12;

  static ThemeData light() => _materialTheme(Brightness.light);

  static ThemeData dark() => _materialTheme(Brightness.dark);

  static ThemeData _materialTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scaffoldColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final fg = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.accentDark : AppColors.accentLight,
      onPrimary: isDark ? AppColors.foregroundLight : AppColors.foregroundDark,
      secondary: isDark ? AppColors.cardDark : AppColors.cardLight,
      onSecondary: fg,
      surface: scaffoldColor,
      onSurface: fg,
      error: AppColors.destructive,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldColor,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      textTheme: Typography.material2021(
        platform: TargetPlatform.android,
      ).black.apply(
            bodyColor: fg,
            displayColor: fg,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      iconTheme: IconThemeData(color: fg),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ShadThemeData shadLight() => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(_radius)),
        cardTheme: const ShadCardTheme(
          backgroundColor: Color(0xFFF4F4F5),
          shadows: <BoxShadow>[],
        ),
      );

  static ShadThemeData shadDark() => ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
        radius: const BorderRadius.all(Radius.circular(_radius)),
        cardTheme: const ShadCardTheme(
          backgroundColor: Color(0xFF18181B),
          shadows: <BoxShadow>[],
        ),
      );
}