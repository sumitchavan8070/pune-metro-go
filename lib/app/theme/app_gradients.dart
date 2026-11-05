import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryPurple, AppColors.secondaryTeal],
  );

  static LinearGradient soft(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.elevatedDark, AppColors.darkSurface],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primaryPurpleLight, AppColors.secondaryTealLight],
    );
  }
}
