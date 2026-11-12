import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_interchange_badge.dart';
import 'package:pune_metro_guide/app/widgets/pm_route_timeline.dart';
import 'package:pune_metro_guide/app/widgets/pm_status_chip.dart';
import 'package:pune_metro_guide/modules/journey_planner/controllers/journey_planner_controller.dart';
import 'package:pune_metro_guide/modules/stations/controllers/station_controller.dart';

class StationDetailView extends GetView<StationDetailController> {
  const StationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(title: const Text('Station')),
      body: Obx(() {
        if (controller.loading.value) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.screenPadding),
            child: PmLoadingSkeleton(),
          );
        }
        if (controller.error.value != null) {
          return PmErrorState(message: controller.error.value!);
        }
        final station = controller.station.value!;
        final previous = controller.neighbor(-1);
        final next = controller.neighbor(1);
        final lineColorValue = controller.lines.isEmpty ? AppColors.primary(brightness) : lineColor(controller.lines.first.color);
        final muted = AppColors.textSecondary(brightness);
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 280),
              builder: (context, value, child) => Transform.scale(scale: value, alignment: Alignment.centerLeft, child: child),
              child: PmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 42, height: 4, decoration: BoxDecoration(color: lineColorValue, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 12),
                    Text(station.name, style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final line in controller.lines)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lineColor(line.color).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(line.name, style: AppTextStyles.caption.copyWith(color: lineColor(line.color))),
                          ),
                        PmStatusChip(status: station.operationalStatus),
                        if (station.isInterchange) const PmInterchangeBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (station.description != null) ...[
              const SizedBox(height: 12),
              Text(station.description!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 16),
            Text('Along the line', style: AppTextStyles.titleLarge),
            PmRouteTimeline(
              color: lineColorValue,
              stops: [
                PmTimelineStop(
                  title: previous?.name ?? 'No previous station',
                  subtitle: 'Previous station',
                  dimmed: previous == null,
                  onTap: previous == null ? null : () => Get.offNamed('/stations/${previous.id}'),
                ),
                PmTimelineStop(title: station.name, subtitle: 'This station', interchange: station.isInterchange),
                PmTimelineStop(
                  title: next?.name ?? 'No next station',
                  subtitle: 'Next station',
                  dimmed: next == null,
                  onTap: next == null ? null : () => Get.offNamed('/stations/${next.id}'),
                ),
              ],
            ),
            Text('Interchange', style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            if (controller.interchanges.isEmpty && controller.lines.length < 2)
              Text('No interchange is listed for this station.', style: AppTextStyles.bodyMedium)
            else ...[
              if (controller.lines.length > 1)
                Text(
                  'This station is on more than one line.',
                  style: AppTextStyles.bodyMedium,
                ),
              for (final interchange in controller.interchanges)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(interchange.interchangeName ?? 'Interchange', style: AppTextStyles.titleMedium),
                  subtitle: Text(
                    '${interchange.fromName} and ${interchange.toName}. '
                    '${interchange.walkingMinutes == null ? 'Walking time is not listed.' : '${interchange.walkingMinutes} min walk.'}',
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Text('Facilities', style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            if (controller.facilities.isEmpty)
              Text(
                'Station facilities are not listed yet.',
                style: AppTextStyles.bodyMedium,
              )
            else
              for (final facility in controller.facilities)
                Text(
                  '${facility.facilityType}${facility.description == null || facility.description!.isEmpty ? '' : ': ${facility.description}'}',
                  style: AppTextStyles.bodyMedium,
                ),
            if (station.address != null) ...[
              const SizedBox(height: 12),
              Text('Location', style: AppTextStyles.titleLarge),
              const SizedBox(height: 6),
              Text(station.address!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 12),
            Text('Service', style: AppTextStyles.titleLarge),
            if (controller.timetables.isEmpty)
              Text('No service window is listed for this station.', style: AppTextStyles.bodyMedium)
            else
              for (final table in controller.timetables)
                Text(
                  '${table.lineName}: first ${formatClock(table.firstTrainTime)}, last ${formatClock(table.lastTrainTime)}.',
                  style: AppTextStyles.bodyMedium,
                ),
            if (controller.aliases.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Also called ${controller.aliases.map((alias) => alias.alias).join(', ')}.', style: AppTextStyles.bodySmall),
            ],
            const SizedBox(height: 16),
            PmPrimaryButton(
              label: station.isBoardable ? 'Plan from here' : 'Not open for boarding',
              onPressed: station.isBoardable
                  ? () {
                      Get.find<JourneyPlannerController>().prefill(station.id, null);
                      Get.until((route) => route.isFirst);
                      Get.toNamed(AppRoutes.plan);
                    }
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
