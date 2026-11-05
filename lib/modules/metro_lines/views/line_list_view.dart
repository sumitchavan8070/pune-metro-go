import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_metro_line_card.dart';
import 'package:pune_metro_guide/modules/metro_lines/controllers/line_controller.dart';

class LineListView extends GetView<LineListController> {
  const LineListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metro lines')),
      body: Obx(() {
        if (controller.loading.value) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.screenPadding),
            child: PmLoadingSkeleton(),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: controller.lines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final line = controller.lines[index];
            return PmMetroLineCard(
              line: line,
              onTap: () => Get.toNamed('/lines/${line.id}'),
            );
          },
        );
      }),
    );
  }
}
