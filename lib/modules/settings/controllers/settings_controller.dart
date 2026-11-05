import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';

class SettingsController extends GetxController {
  final version = ''.obs;
  final meta = <String, String>{}.obs;
  var _taps = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version.value = '${info.version} (${info.buildNumber})';
    meta.assignAll(await Get.find<MetroRepository>().meta());
  }

  void onVersionTap() {
    _taps += 1;
    if (_taps >= 7) {
      _taps = 0;
      Get.toNamed(AppRoutes.developer);
    }
  }

}
