import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';
import 'package:pune_metro_guide/modules/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF120B4A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppConstants.splashAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Obx(() {
              if (controller.loading.value) {
                return const Align(
                  alignment: Alignment(0, 0.78),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.white,
                    ),
                  ),
                );
              }
              final message = controller.error.value;
              if (message == null) {
                return const SizedBox.shrink();
              }
              return Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xE6120B4A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: 12),
                            PmPrimaryButton(label: 'Try again', onPressed: controller.start),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
