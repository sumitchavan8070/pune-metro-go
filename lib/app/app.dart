import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/routes/app_pages.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/theme/app_theme.dart';
import 'package:pune_metro_guide/modules/settings/controllers/theme_controller.dart';

class PuneMetroApp extends StatelessWidget {
  const PuneMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: theme.mode.value,
        builder: (context, child) {
          final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
          final useDark = theme.mode.value == ThemeMode.dark ||
              (theme.mode.value == ThemeMode.system && platformDark);
          return AnimatedTheme(
            data: useDark ? AppTheme.dark : AppTheme.light,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
