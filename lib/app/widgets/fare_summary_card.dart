import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/models/fare_model.dart';

class FareSummaryCard extends StatelessWidget {
  const FareSummaryCard({super.key, required this.quote});

  final FareQuote quote;

  @override
  Widget build(BuildContext context) {
    return PmCard(
      child: quote.available
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verified fare', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  '${quote.currency} ${quote.amount?.toStringAsFixed(0)}',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text('Source: ${quote.sourceName ?? 'Recorded source'}', style: AppTextStyles.bodySmall),
                Text('Effective: ${formatDate(quote.validFrom)}', style: AppTextStyles.bodySmall),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verified fare unavailable', style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text(quote.message, style: AppTextStyles.bodyMedium),
              ],
            ),
    );
  }
}
