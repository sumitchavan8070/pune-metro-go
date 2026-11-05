import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/alert_repository.dart';
import 'package:pune_metro_guide/models/service_alert_model.dart';

class AlertsController extends GetxController {
  final active = <ServiceAlertModel>[].obs;
  final expired = <ServiceAlertModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final all = await Get.find<AlertRepository>().all();
    final now = DateTime.now();
    active.assignAll(all.where((alert) => alert.isActiveAt(now)));
    expired.assignAll(all.where((alert) => !alert.isActiveAt(now)));
  }
}
