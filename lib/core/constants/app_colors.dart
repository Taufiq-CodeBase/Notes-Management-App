import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Surface
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF09090B);

  // Card
  static const Color cardLight = Color(0xFFF4F4F5);
  static const Color cardDark = Color(0xFF18181B);

  // Muted
  static const Color mutedLight = Color(0xFF71717A);
  static const Color mutedDark = Color(0xFFA1A1AA);

  // Foreground
  static const Color foregroundLight = Color(0xFF09090B);
  static const Color foregroundDark = Color(0xFFFAFAFA);

  // Accent
  static const Color accentLight = Color(0xFF18181B);
  static const Color accentDark = Color(0xFFFAFAFA);

  // Destructive
  static const Color destructive = Color(0xFFDC2626);

  // Subtle separator
  static const Color separatorLight = Color(0xFFE4E4E7);
  static const Color separatorDark = Color(0xFF27272A);

  static Color foregroundFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? foregroundDark
          : foregroundLight;

  static Color mutedFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? mutedDark : mutedLight;

  static Color cardFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;

  static Color surfaceFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;
}