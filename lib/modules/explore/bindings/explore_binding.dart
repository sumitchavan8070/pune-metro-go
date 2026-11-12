import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/explore/controllers/explore_controller.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ExploreController.new);
  }
}

class ExploreDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ExploreDetailController.new, fenix: true);
  }
}
