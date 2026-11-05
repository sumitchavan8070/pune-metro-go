import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_route_timeline.dart';
import 'package:pune_metro_guide/models/route_model.dart';

class JourneyRouteCard extends StatelessWidget {
  const JourneyRouteCard({
    super.key,
    required this.plan,
    required this.index,
    this.onShowMap,
  });

  final JourneyPlan plan;
  final int index;
  final VoidCallback? onShowMap;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    final duration = plan.estimatedMinutes == null
        ? 'Duration not published for every leg'
        : 'Estimated about ${plan.estimatedMinutes} min';
    return PmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route ${index + 1}', style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${plan.intervalCount} intervals · ${plan.transferCount} interchange${plan.transferCount == 1 ? '' : 's'} · $duration',
            style: AppTextStyles.bodySmall.copyWith(color: muted),
          ),
          const SizedBox(height: 12),
          for (var legIndex = 0; legIndex < plan.legs.length; legIndex++) ...[
            Text(plan.legs[legIndex].lineName, style: AppTextStyles.labelLarge.copyWith(color: lineColor(plan.legs[legIndex].colorHex))),
            if (plan.legs[legIndex].estimatedMinutes != null)
              Text(
                'Estimated about ${plan.legs[legIndex].estimatedMinutes} min on this line.',
                style: AppTextStyles.caption.copyWith(color: muted),
              )
            else if (plan.legs[legIndex].estimateNote != null)
              Text(plan.legs[legIndex].estimateNote!, style: AppTextStyles.caption.copyWith(color: muted)),
            PmRouteTimeline(
              color: lineColor(plan.legs[legIndex].colorHex),
              stops: [
                for (var stopIndex = 0; stopIndex < plan.legs[legIndex].stops.length; stopIndex++)
                  PmTimelineStop(
                    title: plan.legs[legIndex].stops[stopIndex].station.name,
                    subtitle: plan.legs[legIndex].stops[stopIndex].boards ? null : 'Not open for boarding',
                    dimmed: !plan.legs[legIndex].stops[stopIndex].boards,
                    interchange: legIndex < plan.legs.length - 1 &&
                        stopIndex == plan.legs[legIndex].stops.length - 1,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          for (final notice in plan.notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(notice, style: AppTextStyles.bodySmall.copyWith(color: muted)),
            ),
          if (onShowMap != null)
            TextButton(onPressed: onShowMap, child: const Text('Show on map')),
        ],
      ),
    );
  }
}

class JourneyFailureCard extends StatelessWidget {
  const JourneyFailureCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: PmCard(child: Text(message, style: AppTextStyles.bodyMedium)),
    );
  }
}
