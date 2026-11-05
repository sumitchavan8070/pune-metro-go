import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/models/service_alert_model.dart';

class PmServiceAlertCard extends StatelessWidget {
  const PmServiceAlertCard({super.key, required this.alert});

  final ServiceAlertModel alert;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(alert.title, style: AppTextStyles.titleMedium)),
              ],
            ),
            if (alert.description != null) ...[
              const SizedBox(height: 8),
              Text(alert.description!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(
              '${alert.sourceName ?? 'Source recorded'} · ${formatDate(alert.startTime)} to ${formatDate(alert.endTime)}',
              style: AppTextStyles.caption.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
