import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';

class RouteMapController extends GetxController {
  final lines = <MetroLineModel>[].obs;
  final byLine = <int, List<StationModel>>{}.obs;
  final geographic = true.obs;
  final loading = true.obs;
  final selectedLineId = RxnInt();
  final selectedStationId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final repository = Get.find<MetroRepository>();
    final loaded = await repository.lines();
    lines.assignAll(loaded);
    final map = <int, List<StationModel>>{};
    for (final line in loaded) {
      map[line.id] = await repository.stationsOnLine(line.id);
    }
    byLine.assignAll(map);
    MetroLineModel? initial;
    for (final line in loaded) {
      if ((map[line.id] ?? const <StationModel>[]).isNotEmpty) {
        initial = line;
        break;
      }
    }
    initial ??= loaded.isEmpty ? null : loaded.first;
    selectedLineId.value = initial?.id;
    final firstStations = initial == null ? const <StationModel>[] : map[initial.id] ?? const <StationModel>[];
    selectedStationId.value = firstStations.isEmpty ? null : firstStations.first.id;
    loading.value = false;
  }

  MetroLineModel? get selectedLine {
    final id = selectedLineId.value;
    for (final line in lines) {
      if (line.id == id) {
        return line;
      }
    }
    return null;
  }

  List<StationModel> get selectedStations {
    final id = selectedLineId.value;
    if (id == null) {
      return const [];
    }
    return byLine[id] ?? const [];
  }

  void selectLine(int id) {
    if (selectedLineId.value == id) {
      return;
    }
    selectedLineId.value = id;
    final stations = byLine[id] ?? const <StationModel>[];
    selectedStationId.value = stations.isEmpty ? null : stations.first.id;
  }

  void selectStation(int id) {
    selectedStationId.value = id;
  }

  void stepStation(int delta) {
    final stations = selectedStations;
    final index = stations.indexWhere((station) => station.id == selectedStationId.value);
    final next = index + delta;
    if (index < 0 || next < 0 || next >= stations.length) {
      return;
    }
    selectedStationId.value = stations[next].id;
  }
}
