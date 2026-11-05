import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/home/controllers/home_controller.dart';
import 'package:pune_metro_guide/modules/journey_planner/controllers/journey_planner_controller.dart';
import 'package:pune_metro_guide/modules/route_map/controllers/route_map_controller.dart';
import 'package:pune_metro_guide/modules/shell/controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ShellController.new);
    Get.lazyPut(HomeController.new);
    Get.lazyPut(JourneyPlannerController.new);
    Get.lazyPut(RouteMapController.new);
  }
}
