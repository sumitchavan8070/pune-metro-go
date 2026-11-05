import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';

class PmLoadingSkeleton extends StatefulWidget {
  const PmLoadingSkeleton({super.key, this.lines = 3});

  final int lines;

  @override
  State<PmLoadingSkeleton> createState() => _PmLoadingSkeletonState();
}

class _PmLoadingSkeletonState extends State<PmLoadingSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final base = brightness == Brightness.dark ? AppColors.elevatedDark : AppColors.borderLight;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            for (var index = 0; index < widget.lines; index++)
              Container(
                height: index == 0 ? 120 : 64,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: base.withValues(alpha: 0.45 + (_controller.value * 0.35)),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PmEmptyState extends StatelessWidget {
  const PmEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: muted, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(message, style: AppTextStyles.bodySmall.copyWith(color: muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class PmErrorState extends StatelessWidget {
  const PmErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            PmPrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

class PmOfflineBanner extends StatelessWidget {
  const PmOfflineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Text(message, style: AppTextStyles.bodySmall),
    );
  }
}

class PmLastUpdatedLabel extends StatelessWidget {
  const PmLastUpdatedLabel({super.key, this.extractedAt, this.importedAt});

  final String? extractedAt;
  final String? importedAt;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    return Text(
      'Data extracted ${_short(extractedAt)} · saved on this phone ${_short(importedAt)}',
      style: AppTextStyles.caption.copyWith(color: muted),
    );
  }

  String _short(String? value) {
    if (value == null || value.isEmpty) {
      return 'not recorded';
    }
    return value.length >= 10 ? value.substring(0, 10) : value;
  }
}
