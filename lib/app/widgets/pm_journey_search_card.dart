import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_gradients.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';

class PmJourneySearchCard extends StatelessWidget {
  const PmJourneySearchCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.onOrigin,
    required this.onDestination,
    required this.onSwap,
    required this.onSearch,
    this.loading = false,
  });

  final String origin;
  final String destination;
  final VoidCallback onOrigin;
  final VoidCallback onDestination;
  final VoidCallback onSwap;
  final VoidCallback? onSearch;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return PmCard(
      radius: AppRadius.cardLarge,
      gradient: AppGradients.soft(brightness),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 72,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: 14),
          Text('Where do you want to go?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 14),
          PmEndpointField(label: 'From', value: origin, onTap: onOrigin),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              tooltip: 'Swap origin and destination',
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert),
            ),
          ),
          PmEndpointField(label: 'To', value: destination, onTap: onDestination),
          const SizedBox(height: 14),
          PmPrimaryButton(
            label: 'Search journey',
            icon: Icons.search,
            loading: loading,
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}

class PmEndpointField extends StatelessWidget {
  const PmEndpointField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Material(
      color: AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border(brightness)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness))),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
