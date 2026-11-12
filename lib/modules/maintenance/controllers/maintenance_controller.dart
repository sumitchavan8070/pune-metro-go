import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/startup/app_startup.dart';
import 'package:pune_metro_guide/app/widgets/app_update_dialog.dart';
import 'package:pune_metro_guide/models/app_release_config.dart';

class MaintenanceController extends GetxController {
  final release = AppReleaseConfig.inactive(0).obs;
  final checking = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is AppReleaseConfig) {
      release.value = arguments;
    }
  }

  Future<void> recheck() async {
    if (checking.value) {
      return;
    }
    checking.value = true;
    error.value = null;
    try {
      final gate = await AppStartup.evaluate();
      if (gate.kind == AppGateKind.maintenance) {
        release.value = gate.release;
        return;
      }
      if (gate.kind == AppGateKind.forceUpdate) {
        await showAppUpdateDialog(gate.release, force: true);
        return;
      }
      await Get.offAllNamed(AppRoutes.shell);
    } catch (caught) {
      error.value = 'The metro data could not be loaded.\n$caught';
    } finally {
      checking.value = false;
    }
  }
}
