import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_status_chip.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';

class PmMetroLineCard extends StatelessWidget {
  const PmMetroLineCard({
    super.key,
    required this.line,
    required this.onTap,
    this.operationalStations,
  });

  final MetroLineModel line;
  final VoidCallback onTap;
  final int? operationalStations;

  @override
  Widget build(BuildContext context) {
    final color = lineColor(line.color);
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return PmCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 64,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${line.originName ?? 'Origin unpublished'} to ${line.destinationName ?? 'Destination unpublished'}',
                  style: AppTextStyles.bodySmall.copyWith(color: muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (operationalStations != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '$operationalStations verified operational',
                    style: AppTextStyles.caption.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PmStatusChip(status: line.operationalStatus),
              const SizedBox(height: 10),
              Text('Route', style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
