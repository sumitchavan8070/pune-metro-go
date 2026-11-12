import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/fare_summary_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_journey_search_card.dart';
import 'package:pune_metro_guide/modules/fare_calculator/controllers/fare_controller.dart';

class FareView extends GetView<FareController> {
  const FareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fare calculator')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            Text(
              'Fares follow the Purple and Aqua chart. Pick two stations on that chart.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            PmEndpointField(
              label: 'From',
              value: controller.origin.value?.name ?? 'Choose origin',
              onTap: () => controller.pick(true),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                tooltip: 'Swap origin and destination',
                onPressed: controller.swap,
                icon: const Icon(Icons.swap_vert),
              ),
            ),
            PmEndpointField(
              label: 'To',
              value: controller.destination.value?.name ?? 'Choose destination',
              onTap: () => controller.pick(false),
            ),
            const SizedBox(height: 16),
            if (controller.quote.value != null)
              FareSummaryCard(
                quote: controller.quote.value!,
                routeLabel: _routeLabel(),
              ),
          ],
        ),
      ),
    );
  }

  String? _routeLabel() {
    final from = controller.origin.value?.name;
    final to = controller.destination.value?.name;
    if (from == null || to == null) {
      return null;
    }
    return '$from to $to';
  }
}
