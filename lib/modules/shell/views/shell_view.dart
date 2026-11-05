import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/widgets/pm_bottom_navigation.dart';
import 'package:pune_metro_guide/modules/home/views/home_view.dart';
import 'package:pune_metro_guide/modules/journey_planner/views/journey_planner_view.dart';
import 'package:pune_metro_guide/modules/route_map/views/route_map_view.dart';
import 'package:pune_metro_guide/modules/shell/controllers/shell_controller.dart';
import 'package:pune_metro_guide/modules/shell/views/more_view.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.index.value,
          children: const [
            HomeView(),
            JourneyPlannerView(),
            RouteMapView(),
            MoreView(),
          ],
        ),
        bottomNavigationBar: PmBottomNavigation(
          index: controller.index.value,
          onChanged: controller.select,
        ),
      ),
    );
  }
}
