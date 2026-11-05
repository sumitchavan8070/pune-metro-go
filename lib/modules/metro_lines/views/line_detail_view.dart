import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_route_timeline.dart';
import 'package:pune_metro_guide/app/widgets/pm_status_chip.dart';
import 'package:pune_metro_guide/app/widgets/timetable_card.dart';
import 'package:pune_metro_guide/modules/metro_lines/controllers/line_controller.dart';

class LineDetailView extends GetView<LineDetailController> {
  const LineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Line')),
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
        final line = controller.line.value!;
        final color = lineColor(line.color);
        final muted = AppColors.textSecondary(Theme.of(context).brightness);
        final current = controller.timetables
            .where((item) => item.serviceType == 'regular' && item.isCurrentOn(DateTime.now()))
            .toList();
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 320),
              builder: (context, value, child) => Opacity(opacity: value, child: child),
              child: Row(
                children: [
                  Container(width: 8, height: 48, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(line.name, style: AppTextStyles.headlineLarge)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(line.operatorName ?? '', style: AppTextStyles.bodyMedium.copyWith(color: muted)),
            const SizedBox(height: 8),
            PmStatusChip(status: line.operationalStatus),
            const SizedBox(height: 8),
            Text(operationalStatus(line.operationalStatus).explanation, style: AppTextStyles.bodySmall.copyWith(color: muted)),
            const SizedBox(height: 12),
            Text(
              '${line.originName ?? 'Origin not published'} to ${line.destinationName ?? 'Destination not published'}',
              style: AppTextStyles.titleMedium,
            ),
            Text(
              'Length ${formatKilometres(line.routeLengthKm)} (${verificationLabel(line.lengthVerification ?? 'unavailable')})',
              style: AppTextStyles.bodySmall.copyWith(color: muted),
            ),
            if (!line.colorIsOfficial)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'The colour on this screen is for display. An official line colour was not published in the sources checked.',
                  style: AppTextStyles.bodySmall.copyWith(color: muted),
                ),
              ),
            if (line.notes != null) ...[
              const SizedBox(height: 12),
              Text(line.notes!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(
              'Source: ${line.sourceName ?? 'Recorded with the import.'} · ${verificationLabel(line.verificationStatus)}',
              style: AppTextStyles.caption.copyWith(color: muted),
            ),
            const SizedBox(height: 18),
            Text('Stations', style: AppTextStyles.titleLarge),
            if (controller.stations.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No station list was published for this corridor, so none is shown.'),
              )
            else
              PmRouteTimeline(
                color: color,
                stops: [
                  for (final station in controller.stations)
                    PmTimelineStop(
                      title: station.name,
                      subtitle: [
                        operationalStatus(station.operationalStatus).label,
                        if (station.aliasNames.isNotEmpty) 'Also called ${station.aliasNames.join(', ')}',
                      ].join(' · '),
                      dimmed: !station.isBoardable,
                      interchange: station.isInterchange,
                      onTap: () => Get.toNamed('/stations/${station.id}'),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            Text('Service window', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            if (current.isEmpty)
              Text('No current verified timetable is stored for this line.', style: AppTextStyles.bodyMedium)
            else
              TimetableCard(timetable: current.first, accent: color),
          ],
        );
      }),
    );
  }
}
