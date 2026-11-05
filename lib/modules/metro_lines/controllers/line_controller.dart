import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class LineListController extends GetxController {
  final lines = <MetroLineModel>[].obs;
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    lines.assignAll(await Get.find<MetroRepository>().lines());
    loading.value = false;
  }
}

class LineDetailController extends GetxController {
  final line = Rxn<MetroLineModel>();
  final stations = <StationModel>[].obs;
  final timetables = <TimetableModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null) {
      error.value = 'This line could not be opened.';
      loading.value = false;
      return;
    }
    final repository = Get.find<MetroRepository>();
    line.value = await repository.line(id);
    if (line.value == null) {
      error.value = 'This line is not in the saved metro data.';
      loading.value = false;
      return;
    }
    stations.assignAll(await repository.stationsOnLine(id));
    timetables.assignAll(await Get.find<TimetableRepository>().forLine(id));
    loading.value = false;
  }
}
