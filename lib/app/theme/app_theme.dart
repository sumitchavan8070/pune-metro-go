import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = AppColors.primary(brightness);
    final secondary = AppColors.secondary(brightness);
    final onSurface = AppColors.textPrimary(brightness);
    final muted = AppColors.textSecondary(brightness);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: AppColors.white,
      secondary: secondary,
      onSecondary: AppColors.midnightNavy,
      surface: AppColors.surface(brightness),
      onSurface: onSurface,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.border(brightness),
    );

    final text = TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    final radius = BorderRadius.circular(AppRadius.card);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas(brightness),
      fontFamily: AppTextStyles.family,
      textTheme: text,
      primaryTextTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas(brightness),
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface(brightness),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: AppColors.border(brightness)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.elevatedDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: onSurface),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: muted),
      ),
      dividerColor: AppColors.border(brightness),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.elevatedDark : AppColors.backgroundLight,
        selectedColor: isDark ? AppColors.primaryPurpleDark : AppColors.primaryPurpleLight,
        labelStyle: AppTextStyles.caption.copyWith(color: onSurface),
        side: BorderSide(color: AppColors.border(brightness)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: isDark ? AppColors.elevatedDark : AppColors.white,
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            color: selected ? primary : muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted, size: AppDimensions.icon);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.backgroundDark : AppColors.white,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: muted),
        labelStyle: AppTextStyles.labelLarge.copyWith(color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _inputBorder(AppColors.border(brightness)),
        enabledBorder: _inputBorder(AppColors.border(brightness)),
        focusedBorder: _inputBorder(primary, width: 1.6),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.6),
        disabledBorder: _inputBorder(AppColors.border(brightness)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          backgroundColor: primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.8),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.45)),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.elevatedDark : AppColors.midnightNavy,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: onSurface),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(color: muted),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
