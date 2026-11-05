import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_journey_search_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_metro_line_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_section_header.dart';
import 'package:pune_metro_guide/app/widgets/pm_service_alert_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_station_tile.dart';
import 'package:pune_metro_guide/modules/home/controllers/home_controller.dart';
import 'package:pune_metro_guide/modules/journey_planner/controllers/journey_planner_controller.dart';
import 'package:pune_metro_guide/modules/settings/controllers/theme_controller.dart';
import 'package:pune_metro_guide/modules/shell/controllers/shell_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = Get.find<JourneyPlannerController>();
    return SafeArea(
      child: Obx(() {
        if (controller.loading.value) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.screenPadding),
            child: PmLoadingSkeleton(lines: 4),
          );
        }
        if (controller.error.value != null) {
          return PmErrorState(message: controller.error.value!, onRetry: controller.load);
        }
        final muted = AppColors.textSecondary(Theme.of(context).brightness);
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.spaceSm,
              AppDimensions.screenPadding,
              AppDimensions.spaceXl,
            ),
            children: [


              const SizedBox(height: AppDimensions.spaceMd),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: AppTextStyles.bodyMedium.copyWith(color: muted)),
                        const SizedBox(height: 2),
                        Text('Pune', style: AppTextStyles.headlineLarge),
                      ],
                    ),
                  ),
                  const _HomeThemeToggle(),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              PmJourneySearchCard(
                origin: planner.origin.value?.name ?? 'Choose a station',
                destination: planner.destination.value?.name ?? 'Choose a station',
                onOrigin: planner.pickOrigin,
                onDestination: planner.pickDestination,
                onSwap: planner.swap,
                loading: planner.planning.value,
                onSearch: planner.planning.value
                    ? null
                    : () async {
                        if (planner.origin.value == null || planner.destination.value == null) {
                          Get.find<ShellController>().select(1);
                          return;
                        }
                        await planner.plan();
                        Get.find<ShellController>().select(1);
                      },
              ),
              const PmSectionHeader(title: 'Metro lines', action: 'All lines', onAction: _openLines),
              for (final line in controller.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PmMetroLineCard(
                    line: line,
                    operationalStations: controller.operationalCounts[line.id],
                    onTap: () => Get.toNamed('/lines/${line.id}'),
                  ),
                ),
              const PmSectionHeader(title: 'Nearby stations'),
              if (controller.nearbyLoading.value && controller.nearby.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
              for (final item in controller.nearby)
                PmStationTile(
                  station: item.station,
                  subtitle: formatDistanceMetres(item.metres),
                  onTap: () => Get.toNamed('/stations/${item.station.id}'),
                ),
              if (controller.nearby.isEmpty && controller.nearbyMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(controller.nearbyMessage.value!, style: AppTextStyles.bodySmall.copyWith(color: muted)),
                ),
              if (controller.nearby.isNotEmpty && controller.nearbyMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(controller.nearbyMessage.value!, style: AppTextStyles.bodySmall.copyWith(color: muted)),
                ),
              const PmSectionHeader(title: 'Quick actions'),
              _QuickActions(onNearby: controller.findNearby),
              if (controller.alerts.isNotEmpty) ...[
                const PmSectionHeader(title: 'Service alerts'),
                for (final alert in controller.alerts) PmServiceAlertCard(alert: alert),
              ],
              const SizedBox(height: AppDimensions.spaceMd),
              PmLastUpdatedLabel(
                extractedAt: controller.extractedAt.value,
                importedAt: controller.importedAt.value,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

void _openLines() => Get.toNamed(AppRoutes.lines);

class _HomeThemeToggle extends StatelessWidget {
  const _HomeThemeToggle();

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Obx(() {
      final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final isDark = theme.mode.value == ThemeMode.dark ||
          (theme.mode.value == ThemeMode.system && platformDark);
      final brightness = Theme.of(context).brightness;
      final primary = AppColors.primary(brightness);
      return Material(
        color: brightness == Brightness.dark ? AppColors.elevatedDark : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: AppColors.border(brightness)),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          onTap: () => theme.setMode(isDark ? ThemeMode.light : ThemeMode.dark),
          child: SizedBox(
            width: 64,
            height: 32,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Icon(
                            Icons.light_mode_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.textSecondary(brightness)
                                : AppColors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Icon(
                            Icons.dark_mode_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textSecondary(brightness),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    });
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNearby});

  final VoidCallback onNearby;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, String?, int?)>[
      (Icons.schedule, 'Timetable', AppRoutes.timetable, null),
      (Icons.payments_outlined, 'Fare calculator', AppRoutes.fares, null),
      (Icons.map_outlined, 'Metro map', null, 2),
      (Icons.near_me_outlined, 'Nearby stations', null, null),
    ];
    final brightness = Theme.of(context).brightness;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.3,
      children: [
        for (final action in actions)
          Material(
            color: AppColors.surface(brightness),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: AppColors.border(brightness)),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
              onTap: () {
                if (action.$4 != null) {
                  Get.find<ShellController>().select(action.$4!);
                } else if (action.$3 != null) {
                  Get.toNamed(action.$3!);
                } else {
                  onNearby();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(action.$1, color: AppColors.primary(brightness)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(action.$2, style: AppTextStyles.labelLarge, maxLines: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
