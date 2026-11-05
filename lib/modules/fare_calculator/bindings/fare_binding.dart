import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/fare_calculator/controllers/fare_controller.dart';

class FareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(FareController.new);
  }
}
