import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/timetable_card.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/modules/timetable/controllers/timetable_controller.dart';

class TimetableView extends GetView<TimetableController> {
  const TimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: Obx(() {
        if (controller.loading.value) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.screenPadding),
            child: PmLoadingSkeleton(),
          );
        }
        final brightness = Theme.of(context).brightness;
        final muted = AppColors.textSecondary(brightness);
        final selected = _selectedLine();
        final accent = selected == null ? AppColors.primary(brightness) : lineColor(selected.color);
        final current = controller.visible
            .where((table) => table.isCurrentOn(DateTime.now()) && table.serviceType == 'regular')
            .toList();
        final history = controller.visible
            .where((table) => !table.isCurrentOn(DateTime.now()) || table.serviceType != 'regular')
            .toList();
        final dayTypes = controller.tables.map((table) => table.serviceDayType).toSet().toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spaceSm,
            AppDimensions.screenPadding,
            AppDimensions.spaceXl,
          ),
          children: [
            PmCard(
              child: Row(
                children: [
                  Icon(Icons.schedule, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scheduled service windows. This screen does not track trains.',
                      style: AppTextStyles.bodyMedium.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Text('Line', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.lines.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final line = controller.lines[index];
                  final active = line.id == controller.lineId.value;
                  final color = lineColor(line.color);
                  return ChoiceChip(
                    label: Text(line.name),
                    selected: active,
                    showCheckmark: false,
                    avatar: CircleAvatar(backgroundColor: color, radius: 6),
                    selectedColor: color.withValues(alpha: 0.16),
                    labelStyle: AppTextStyles.labelLarge.copyWith(
                      color: active ? color : AppColors.textPrimary(brightness),
                    ),
                    side: BorderSide(color: active ? color : AppColors.border(brightness)),
                    onSelected: (_) => controller.selectLine(line.id),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Text('Service day', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            if (dayTypes.isEmpty)
              Text('No day types are published for this line.', style: AppTextStyles.bodyMedium.copyWith(color: muted))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in dayTypes)
                    ChoiceChip(
                      label: Text(_dayLabel(type)),
                      selected: controller.dayType.value == type,
                      showCheckmark: false,
                      selectedColor: accent.withValues(alpha: 0.16),
                      labelStyle: AppTextStyles.labelLarge.copyWith(
                        color: controller.dayType.value == type ? accent : AppColors.textPrimary(brightness),
                      ),
                      side: BorderSide(
                        color: controller.dayType.value == type ? accent : AppColors.border(brightness),
                      ),
                      onSelected: (_) => controller.dayType.value = type,
                    ),
                ],
              ),
            const SizedBox(height: AppDimensions.spaceMd),
            if (current.isEmpty)
              const PmEmptyState(
                title: 'No current timetable',
                message: 'A verified first and last train is not stored for this line and day.',
                icon: Icons.schedule,
              )
            else
              for (final table in current) TimetableCard(timetable: table, accent: accent),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Earlier notices', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              for (final table in history) TimetableCard(timetable: table, historical: true, accent: accent),
            ],
          ],
        );
      }),
    );
  }

  MetroLineModel? _selectedLine() {
    for (final line in controller.lines) {
      if (line.id == controller.lineId.value) {
        return line;
      }
    }
    return null;
  }

  String _dayLabel(String type) {
    switch (type) {
      case 'all_days':
        return 'All published days';
      case 'weekday':
        return 'Weekday';
      case 'saturday':
        return 'Saturday';
      case 'sunday_holiday':
        return 'Sunday and holiday';
      case 'festival':
        return 'Festival notice';
      default:
        return type;
    }
  }
}
