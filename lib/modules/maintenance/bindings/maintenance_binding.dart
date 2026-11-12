import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/maintenance/controllers/maintenance_controller.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(MaintenanceController.new);
  }
}
