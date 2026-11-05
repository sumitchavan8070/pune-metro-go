import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_interchange_badge.dart';
import 'package:pune_metro_guide/app/widgets/pm_status_chip.dart';
import 'package:pune_metro_guide/models/station_model.dart';

class PmStationTile extends StatelessWidget {
  const PmStationTile({
    super.key,
    required this.station,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  final StationModel station;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(station.name, style: AppTextStyles.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: muted)),
          if (station.aliasNames.isNotEmpty)
            Text(
              'Also called ${station.aliasNames.join(', ')}',
              style: AppTextStyles.bodySmall.copyWith(color: muted),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              PmStatusChip(status: station.operationalStatus),
              if (station.isInterchange) const PmInterchangeBadge(),
            ],
          ),
        ],
      ),
      isThreeLine: subtitle != null,
      trailing: trailing,
    );
  }
}
