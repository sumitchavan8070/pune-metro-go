import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/widgets/pm_card.dart';
import 'package:pune_metro_guide/models/fare_model.dart';

class FareSummaryCard extends StatelessWidget {
  const FareSummaryCard({super.key, required this.quote, this.routeLabel});

  final FareQuote quote;
  final String? routeLabel;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);
    return PmCard(
      child: quote.available
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chart fare', style: AppTextStyles.caption),
                if (routeLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(routeLabel!, style: AppTextStyles.titleMedium),
                ],
                const SizedBox(height: 4),
                Text(
                  formatMoney(quote.currency, quote.amount),
                  style: AppTextStyles.displayMedium,
                ),
                if (quote.validFrom != null && quote.validFrom!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Effective ${formatDate(quote.validFrom)}',
                    style: AppTextStyles.bodySmall.copyWith(color: muted),
                  ),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No fare shown', style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text(quote.message, style: AppTextStyles.bodyMedium),
              ],
            ),
    );
  }
}
