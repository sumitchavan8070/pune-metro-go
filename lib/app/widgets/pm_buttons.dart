import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';

class PmPrimaryButton extends StatelessWidget {
  const PmPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: _label(loading ? 'Please wait' : label, icon, loading),
    );
  }
}

class PmSecondaryButton extends StatelessWidget {
  const PmSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final color = AppColors.secondary(Theme.of(context).brightness);
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: enabled ? 0.7 : 0.3)),
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
      child: _label(loading ? 'Please wait' : label, icon, loading),
    );
  }
}

Widget _label(String label, IconData? icon, bool loading) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (loading)
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
        )
      else if (icon != null)
        Icon(icon, size: 18),
      if (loading || icon != null) const SizedBox(width: 8),
      Flexible(
        child: Text(label, style: AppTextStyles.labelLarge, overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}
