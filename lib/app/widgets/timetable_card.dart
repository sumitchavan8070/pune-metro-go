import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class TimetableCard extends StatelessWidget {
  const TimetableCard({
    super.key,
    required this.timetable,
    this.historical = false,
    this.accent,
  });

  final TimetableModel timetable;
  final bool historical;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(brightness);
    final color = accent ?? AppColors.primary(brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PmCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 4, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historical ? 'Earlier published notice' : 'Scheduled data',
                    style: AppTextStyles.caption.copyWith(color: historical ? AppColors.warning : muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    historical ? 'Historical service window' : 'Current service window',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_direction(timetable.direction)} · ${verificationLabel(timetable.verificationStatus)}',
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: 'First train',
                          value: formatClock(timetable.firstTrainTime),
                          icon: Icons.wb_sunny_outlined,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TimeTile(
                          label: 'Last train',
                          value: formatClock(timetable.lastTrainTime),
                          icon: Icons.nightlight_outlined,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  if (timetable.peakHeadwayMinutes != null || timetable.offPeakHeadwayMinutes != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (timetable.peakHeadwayMinutes != null)
                          Expanded(
                            child: _TimeTile(
                              label: 'Peak',
                              value: 'Every ${timetable.peakHeadwayMinutes!.toStringAsFixed(0)} min',
                              detail: timetable.peakWindows,
                              icon: Icons.groups_outlined,
                              color: color,
                            ),
                          ),
                        if (timetable.peakHeadwayMinutes != null && timetable.offPeakHeadwayMinutes != null)
                          const SizedBox(width: 10),
                        if (timetable.offPeakHeadwayMinutes != null)
                          Expanded(
                            child: _TimeTile(
                              label: 'Off-peak',
                              value: 'Every ${timetable.offPeakHeadwayMinutes!.toStringAsFixed(0)} min',
                              detail: timetable.offPeakWindows,
                              icon: Icons.schedule,
                              color: color,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (timetable.endToEndMinutes != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Published end-to-end time: ${timetable.endToEndMinutes} min'
                      '${timetable.publishedDistanceKm == null ? '' : ' · ${formatKilometres(timetable.publishedDistanceKm)}'}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Effective ${formatDate(timetable.validFrom)}'
                    '${timetable.validUntil == null ? '' : ' until ${formatDate(timetable.validUntil)}'}',
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                  Text(
                    timetable.sourceName ?? 'Source recorded with the import',
                    style: AppTextStyles.caption.copyWith(color: muted),
                  ),
                  if (timetable.notes != null) ...[
                    const SizedBox(height: 8),
                    Text(timetable.notes!, style: AppTextStyles.bodySmall),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Station-by-station departure times are shown only when a source publishes them. This is a scheduled window, not a live prediction.',
                    style: AppTextStyles.caption.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _direction(String direction) {
    switch (direction) {
      case 'both':
        return 'Both directions';
      case 'up':
        return 'Up direction';
      case 'down':
        return 'Down direction';
      default:
        return direction;
    }
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness))),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.titleMedium),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(detail!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness))),
          ],
        ],
      ),
    );
  }
}
