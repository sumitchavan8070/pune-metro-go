import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_logo.dart';
import 'package:pune_metro_guide/modules/settings/controllers/settings_controller.dart';
import 'package:pune_metro_guide/modules/settings/controllers/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final brightness = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final isDark =
            theme.mode.value == ThemeMode.dark ||
            (theme.mode.value == ThemeMode.system && platformDark);
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
            vertical: AppDimensions.spaceLg,
          ),
          children: [
            PmCard(
              radius: AppRadius.cardLarge,
              child: Column(
                children: [
                  const PmLogo(width: 168),
                  const SizedBox(height: 12),
                  Text(AppConstants.appName, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(AppConstants.tagline, style: AppTextStyles.bodySmall.copyWith(color: muted)),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            PmCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Dark theme is on' : 'Light theme is on',
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                  const SizedBox(height: 14),
                  _ThemeToggle(
                    isDark: isDark,
                    onChanged: (dark) => theme.setMode(dark ? ThemeMode.dark : ThemeMode.light),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            // PmCard(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('Reference data', style: AppTextStyles.titleLarge),
            //       const SizedBox(height: 12),
            //       _InfoRow(
            //         label: 'Dataset',
            //         value: controller.meta['dataset_version'] ?? 'Not imported',
            //       ),
            //       _InfoRow(label: 'Extracted', value: formatDate(controller.meta['extracted_at'])),
            //       _InfoRow(
            //         label: 'Saved on this phone',
            //         value: formatDate(controller.meta['imported_at']),
            //       ),
            //       _InfoRow(
            //         label: 'Database',
            //         value: 'Schema v${AppConstants.databaseVersion}',
            //         last: true,
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: AppDimensions.spaceMd),
            const PmCard(
              child: _IconCopy(
                icon: Icons.lock_outline,
                title: 'Privacy',
                body:
                    'Location is requested only from the nearby-stations action and is not collected in the background. Metro reference data is stored in Firebase and cached on this phone.',
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            PmCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _IconCopy(
                      icon: Icons.info_outline,
                      title: 'About',
                      body:
                          'PuneMetro Go helps passengers read lines, stations, published service windows, and journey options. It does not show live train positions.',
                    ),
                  ),
                  Divider(height: 1, color: AppColors.border(brightness)),
                  ListTile(
                    title: const Text('App version'),
                    subtitle: Text(controller.version.value),
                    trailing: Icon(Icons.chevron_right, color: muted),
                    onTap: controller.onVersionTap,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onChanged});

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primary = AppColors.primary(brightness);
    return Container(
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final half = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: isDark ? half : 0,
                top: 0,
                bottom: 0,
                width: half,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _side(
                      context,
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: !isDark,
                      onTap: () => onChanged(false),
                    ),
                    _side(
                      context,
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: isDark,
                      onTap: () => onChanged(true),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _side(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final idle = AppColors.textSecondary(Theme.of(context).brightness);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.white : idle),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: selected ? AppColors.white : idle),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCopy extends StatelessWidget {
  const _IconCopy({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary(brightness), size: 20),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleLarge),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(brightness)),
        ),
      ],
    );
  }
}
