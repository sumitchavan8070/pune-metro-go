import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class TimetableController extends GetxController {
  final lines = <MetroLineModel>[].obs;
  final tables = <TimetableModel>[].obs;
  final lineId = RxnInt();
  final dayType = 'all_days'.obs;
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    lines.assignAll(await Get.find<MetroRepository>().lines());
    final rideable = lines.where((line) => line.canRide).toList();
    if (rideable.isNotEmpty) {
      await selectLine(rideable.first.id);
    }
    loading.value = false;
  }

  Future<void> selectLine(int id) async {
    lineId.value = id;
    tables.assignAll(await Get.find<TimetableRepository>().forLine(id));
    final types = tables.map((table) => table.serviceDayType).toSet();
    if (!types.contains(dayType.value) && types.isNotEmpty) {
      dayType.value = types.first;
    }
  }

  List<TimetableModel> get visible {
    return tables.where((table) => table.serviceDayType == dayType.value).toList();
  }
}
