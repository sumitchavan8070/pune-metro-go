import 'package:get/get.dart';
import 'package:pune_metro_guide/data/services/app_release_service.dart';
import 'package:pune_metro_guide/data/services/import_service.dart';
import 'package:pune_metro_guide/models/app_release_config.dart';

enum AppGateKind { maintenance, forceUpdate, ready }

class AppGate {
  const AppGate(this.kind, this.release);

  final AppGateKind kind;
  final AppReleaseConfig release;
}

class AppStartup {
  const AppStartup._();

  static Future<AppGate> evaluate() async {
    final release = await Get.find<AppReleaseService>().load();
    if (release.serverMaintenance) {
      return AppGate(AppGateKind.maintenance, release);
    }
    if (release.showForce) {
      return AppGate(AppGateKind.forceUpdate, release);
    }
    await Get.find<ImportService>().ensureImported();
    return AppGate(AppGateKind.ready, release);
  }
}
