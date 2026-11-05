import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_interchange_badge.dart';

class PmTimelineStop {
  const PmTimelineStop({
    required this.title,
    this.subtitle,
    this.interchange = false,
    this.dimmed = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool interchange;
  final bool dimmed;
  final VoidCallback? onTap;
}

class PmRouteTimeline extends StatelessWidget {
  const PmRouteTimeline({super.key, required this.color, required this.stops});

  final Color color;
  final List<PmTimelineStop> stops;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    return Column(
      children: [
        for (var index = 0; index < stops.length; index++)
          _Stop(
            stop: stops[index],
            color: color,
            muted: muted,
            isFirst: index == 0,
            isLast: index == stops.length - 1,
          ),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.stop,
    required this.color,
    required this.muted,
    required this.isFirst,
    required this.isLast,
  });

  final PmTimelineStop stop;
  final Color color;
  final Color muted;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final node = stop.dimmed ? muted : color;
    return InkWell(
      onTap: stop.onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 22,
              child: Column(
                children: [
                  Expanded(
                    child: Container(width: 2, color: isFirst ? Colors.transparent : color.withValues(alpha: 0.45)),
                  ),
                  Container(
                    width: stop.dimmed ? 8 : 12,
                    height: stop.dimmed ? 8 : 12,
                    decoration: BoxDecoration(
                      color: node,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface(Theme.of(context).brightness), width: 2),
                    ),
                  ),
                  Expanded(
                    child: Container(width: 2, color: isLast ? Colors.transparent : color.withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: stop.dimmed ? muted : null,
                        fontWeight: stop.dimmed ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                    if (stop.subtitle != null)
                      Text(stop.subtitle!, style: AppTextStyles.caption.copyWith(color: muted)),
                    if (stop.interchange) ...[
                      const SizedBox(height: 4),
                      const PmInterchangeBadge(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
