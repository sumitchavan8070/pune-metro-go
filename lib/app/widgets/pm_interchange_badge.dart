import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';

class PmInterchangeBadge extends StatelessWidget {
  const PmInterchangeBadge({super.key, this.label = 'Interchange'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.secondary(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
