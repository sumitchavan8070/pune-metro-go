import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_logo.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      extendBody: true,

      body: ListView(
        children: [
          const PmLogo(width: 160),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(AppConstants.appName, style: AppTextStyles.headlineLarge),
                const SizedBox(height: 4),
                Text(AppConstants.tagline, style: AppTextStyles.bodyMedium.copyWith(color: muted)),
                const SizedBox(height: 16),
                _tile(
                  context,
                  'Metro lines',
                  'Operators, distance, and station order',
                  Icons.route,
                  AppRoutes.lines,
                ),
                _tile(
                  context,
                  'Timetable',
                  'Published first train, last train, and frequency',
                  Icons.schedule,
                  AppRoutes.timetable,
                ),
                _tile(
                  context,
                  'Fare calculator',
                  'Only a verified fare is shown',
                  Icons.payments_outlined,
                  AppRoutes.fares,
                ),
                _tile(
                  context,
                  'Service alerts',
                  'Stored notices that are still in date',
                  Icons.campaign_outlined,
                  AppRoutes.alerts,
                ),
                _tile(
                  context,
                  'Settings',
                  'Appearance, data, and permissions',
                  Icons.settings_outlined,
                  AppRoutes.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PmCard(
        onTap: () => Get.toNamed(route),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary(Theme.of(context).brightness)),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
