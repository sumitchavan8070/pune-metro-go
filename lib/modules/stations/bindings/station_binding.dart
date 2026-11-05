import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/stations/controllers/station_controller.dart';

class StationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(StationDetailController.new);
  }
}

class StationPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(StationPickerController.new);
  }
}
