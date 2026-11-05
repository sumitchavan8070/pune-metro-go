import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/metro_lines/controllers/line_controller.dart';

class LineListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(LineListController.new);
  }
}

class LineDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(LineDetailController.new);
  }
}
