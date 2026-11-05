import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/alerts/controllers/alerts_controller.dart';

class AlertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AlertsController.new);
  }
}
