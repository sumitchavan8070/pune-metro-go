import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';

class PmStatusChip extends StatelessWidget {
  const PmStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final presentation = operationalStatus(status);
    final brightness = Theme.of(context).brightness;
    final color = status == 'planned' || status == 'under_construction' || status == 'unavailable'
        ? AppColors.textSecondary(brightness)
        : presentation.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(presentation.label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
