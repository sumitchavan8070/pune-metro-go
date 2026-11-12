import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';
import 'package:pune_metro_guide/modules/maintenance/controllers/maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Obx(
            () {
              final release = controller.release.value;
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Icon(Icons.construction_outlined, size: 42, color: AppColors.primary(brightness)),
                    const SizedBox(height: 16),
                    Text(
                      release.titleFor(maintenance: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      release.messageFor(maintenance: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary(brightness)),
                    ),
                    if (controller.error.value != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        controller.error.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                    const Spacer(),
                    PmPrimaryButton(
                      label: 'Check again',
                      loading: controller.checking.value,
                      onPressed: controller.recheck,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
