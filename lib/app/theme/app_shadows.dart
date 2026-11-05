import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.midnightNavy.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
