import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_service_alert_card.dart';
import 'package:pune_metro_guide/modules/alerts/controllers/alerts_controller.dart';

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service alerts')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            if (controller.active.isEmpty)
              const PmEmptyState(
                title: 'No active alerts',
                message: 'There is no service alert in force right now.',
                icon: Icons.campaign_outlined,
              )
            else
              for (final alert in controller.active) PmServiceAlertCard(alert: alert),
            if (controller.expired.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Expired', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('These notices are no longer in force.'),
              for (final alert in controller.expired) PmServiceAlertCard(alert: alert),
            ],
          ],
        ),
      ),
    );
  }
}
