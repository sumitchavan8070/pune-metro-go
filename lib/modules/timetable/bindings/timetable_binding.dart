import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/timetable/controllers/timetable_controller.dart';

class TimetableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(TimetableController.new);
  }
}
