import 'package:flutter/material.dart';

/// Brand tokens for PuneMetro Go.
/// Metro line colours stay on each line record and are not defined here.
class AppColors {
  const AppColors._();

  static const primaryPurple = Color(0xFF673DE6);
  static const primaryPurpleDark = Color(0xFF4B26B8);
  static const primaryPurpleLight = Color(0xFFEEE9FF);
  static const primaryPurpleOnDark = Color(0xFF8A6AFF);

  static const secondaryTeal = Color(0xFF11B9B0);
  static const secondaryTealDark = Color(0xFF078F89);
  static const secondaryTealLight = Color(0xFFDDF8F5);
  static const secondaryTealOnDark = Color(0xFF35D8CD);

  static const midnightNavy = Color(0xFF101B35);
  static const darkSurface = Color(0xFF172440);
  static const elevatedDark = Color(0xFF1C2B48);
  static const backgroundLight = Color(0xFFF5F6FA);
  static const backgroundDark = Color(0xFF0D1425);

  static const white = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF182238);
  static const textSecondaryLight = Color(0xFF64748B);
  static const textPrimaryDark = Color(0xFFF4F6FC);
  static const textSecondaryDark = Color(0xFFA5B0C5);
  static const borderLight = Color(0xFFE7EAF1);
  static const borderDark = Color(0xFF293650);

  static const success = Color(0xFF16A36A);
  static const warning = Color(0xFFE59A27);
  static const error = Color(0xFFDC4C4C);
  static const info = Color(0xFF3688E8);

  static Color primary(Brightness brightness) =>
      brightness == Brightness.dark ? primaryPurpleOnDark : primaryPurple;

  static Color secondary(Brightness brightness) =>
      brightness == Brightness.dark ? secondaryTealOnDark : secondaryTeal;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? borderDark : borderLight;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : white;

  static Color canvas(Brightness brightness) =>
      brightness == Brightness.dark ? backgroundDark : backgroundLight;
}
