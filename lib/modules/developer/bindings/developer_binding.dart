import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/developer/controllers/developer_controller.dart';

class DeveloperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(DeveloperController.new);
  }
}
