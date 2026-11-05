import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String family = 'Inter';

  static const displayLarge = TextStyle(
    fontFamily: family,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  static const displayMedium = TextStyle(
    fontFamily: family,
    fontSize: 28,
    height: 1.18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static const headlineLarge = TextStyle(
    fontFamily: family,
    fontSize: 24,
    height: 1.22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const headlineMedium = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static const titleLarge = TextStyle(
    fontFamily: family,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const titleMedium = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const bodyLarge = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const bodyMedium = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const labelLarge = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );
}
