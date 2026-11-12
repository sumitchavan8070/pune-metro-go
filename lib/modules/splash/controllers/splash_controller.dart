import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/startup/app_startup.dart';
import 'package:pune_metro_guide/app/widgets/app_update_dialog.dart';

class SplashController extends GetxController {
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    start();
  }

  Future<void> start() async {
    loading.value = true;
    error.value = null;
    try {
      final gate = await AppStartup.evaluate();
      if (gate.kind == AppGateKind.maintenance) {
        loading.value = false;
        await Get.offAllNamed(AppRoutes.maintenance, arguments: gate.release);
        return;
      }
      if (gate.kind == AppGateKind.forceUpdate) {
        loading.value = false;
        await showAppUpdateDialog(gate.release, force: true);
        return;
      }
      await Get.offAllNamed(AppRoutes.shell);
    } catch (caught) {
      final detail = caught.toString();
      final denied = detail.contains('permission-denied') || detail.contains('PERMISSION_DENIED');
      error.value = denied
          ? 'Cloud data is blocked. In the punemetro-go Firebase console, publish the rules from firestore.rules, then try again.\n$detail'
          : 'The metro data could not be loaded from Firebase.\n$detail';
      loading.value = false;
    }
  }
}
