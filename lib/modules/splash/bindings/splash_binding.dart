import 'package:get/get.dart';
import 'package:pune_metro_guide/modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SplashController.new);
  }
}
