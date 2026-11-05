import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/models/interchange_model.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/station_facility_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class StationDetailController extends GetxController {
  final station = Rxn<StationModel>();
  final lines = <MetroLineModel>[].obs;
  final sequence = <StationModel>[].obs;
  final aliases = <StationAliasModel>[].obs;
  final interchanges = <InterchangeModel>[].obs;
  final facilities = <StationFacilityModel>[].obs;
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
      error.value = 'This station could not be opened.';
      loading.value = false;
      return;
    }
    final metro = Get.find<MetroRepository>();
    final loaded = await metro.station(id);
    if (loaded == null) {
      error.value = 'This station is not in the saved metro data.';
      loading.value = false;
      return;
    }
    station.value = loaded;
    lines.assignAll(await metro.linesForStation(id));
    aliases.assignAll(await metro.aliases(id));
    interchanges.assignAll(await metro.interchangesFor(id));
    facilities.assignAll(await metro.facilities(id));
    final tables = <TimetableModel>[];
    for (final line in lines) {
      final rows = await Get.find<TimetableRepository>().forLine(line.id);
      tables.addAll(rows.where((row) => row.serviceType == 'regular' && row.isCurrentOn(DateTime.now())));
    }
    timetables.assignAll(tables);
    if (lines.isNotEmpty) {
      sequence.assignAll(await metro.stationsOnLine(lines.first.id));
    }
    loading.value = false;
  }

  StationModel? neighbor(int delta) {
    final current = station.value;
    if (current == null) {
      return null;
    }
    final index = sequence.indexWhere((item) => item.id == current.id);
    final next = index + delta;
    if (index < 0 || next < 0 || next >= sequence.length) {
      return null;
    }
    return sequence[next];
  }
}

class StationPickerController extends GetxController {
  final results = <StationModel>[].obs;
  final loading = true.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> load() async {
    results.assignAll(await Get.find<MetroRepository>().allStations());
    loading.value = false;
  }

  Future<void> search(String value) async {
    if (value.trim().isEmpty) {
      await load();
      return;
    }
    results.assignAll(await Get.find<MetroRepository>().search(value));
  }
}
