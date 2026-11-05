import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/widgets/fare_summary_card.dart';
import 'package:pune_metro_guide/app/widgets/journey_route_card.dart';
import 'package:pune_metro_guide/app/widgets/pm_journey_search_card.dart';
import 'package:pune_metro_guide/modules/journey_planner/controllers/journey_planner_controller.dart';

class JourneyPlannerView extends GetView<JourneyPlannerController> {
  const JourneyPlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spaceMd,
            AppDimensions.screenPadding,
            AppDimensions.spaceXl,
          ),
          children: [
            Text('Plan Journey', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 6),
            Text(
              'Routes use stations that are open in the stored data. Closed and planned stations are refused.',
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 16),
            PmJourneySearchCard(
              origin: controller.origin.value?.name ?? 'Choose origin',
              destination: controller.destination.value?.name ?? 'Choose destination',
              onOrigin: controller.pickOrigin,
              onDestination: controller.pickDestination,
              onSwap: controller.swap,
              loading: controller.planning.value,
              onSearch: controller.planning.value ? null : controller.plan,
            ),
            if (controller.error.value != null) ...[
              const SizedBox(height: 12),
              Text(controller.error.value!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 16),
            for (var index = 0; index < controller.plans.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: controller.plans[index].success
                    ? JourneyRouteCard(
                        plan: controller.plans[index],
                        index: index,
                        onShowMap: controller.showOnMap,
                      )
                    : JourneyFailureCard(message: controller.plans[index].errorMessage ?? 'No route'),
              ),
            if (controller.quote.value != null) ...[
              Text('Fare', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              FareSummaryCard(quote: controller.quote.value!),
            ],
          ],
        ),
      ),
    );
  }
}
