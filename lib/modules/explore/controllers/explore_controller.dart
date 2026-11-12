import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/modules/explore/data/explore_catalog.dart';

class ExploreStationLink {
  const ExploreStationLink({required this.station, required this.line});

  final StationModel station;
  final MetroLineModel? line;
}

class ExploreController extends GetxController {
  final query = ''.obs;
  final category = ExploreCategory.all.obs;
  final sort = ExploreSort.featured.obs;
  final links = <String, ExploreStationLink>{}.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadLinks();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadLinks() async {
    final metro = Get.find<MetroRepository>();
    final stations = await metro.allStations();
    final byCode = {for (final station in stations) station.code: station};
    final resolved = <String, ExploreStationLink>{};
    for (final place in explorePlaces) {
      final code = place.stationCode;
      if (code == null) {
        continue;
      }
      final station = byCode[code];
      if (station == null || station.operationalStatus != 'operational') {
        continue;
      }
      final lines = await metro.linesForStation(station.id);
      resolved[place.id] = ExploreStationLink(
        station: station,
        line: lines.isEmpty ? null : lines.first,
      );
    }
    links.assignAll(resolved);
  }

  ExploreStationLink? linkFor(ExplorePlace place) => links[place.id];

  List<ExplorePlace> get popular {
    return explorePlaces.where((place) => place.popular).toList();
  }

  List<ExplorePlace> get visible {
    final term = query.value.trim().toLowerCase();
    final selected = category.value;
    final matched = explorePlaces.where((place) {
      if (selected != ExploreCategory.all && place.category != selected) {
        return false;
      }
      if (term.isEmpty) {
        return true;
      }
      final station = linkFor(place)?.station.name.toLowerCase() ?? '';
      final haystack = '${place.name} ${place.summary} ${place.area} ${exploreCategoryLabel(place.category)} $station'
          .toLowerCase();
      return haystack.contains(term);
    }).toList();
    switch (sort.value) {
      case ExploreSort.featured:
        return matched;
      case ExploreSort.distance:
        matched.sort((a, b) {
          final left = a.straightLineMetres;
          final right = b.straightLineMetres;
          if (left == null && right == null) {
            return a.name.compareTo(b.name);
          }
          if (left == null) {
            return 1;
          }
          if (right == null) {
            return -1;
          }
          return left.compareTo(right);
        });
        return matched;
      case ExploreSort.station:
        matched.sort((a, b) {
          final left = linkFor(a)?.station.name;
          final right = linkFor(b)?.station.name;
          if (left == null && right == null) {
            return a.name.compareTo(b.name);
          }
          if (left == null) {
            return 1;
          }
          if (right == null) {
            return -1;
          }
          final byStation = left.compareTo(right);
          return byStation == 0 ? a.name.compareTo(b.name) : byStation;
        });
        return matched;
    }
  }
}

class ExploreDetailController extends GetxController {
  final showMap = false.obs;
  final fitBoth = false.obs;
  ExplorePlace? place;
  ExploreStationLink? link;

  @override
  void onInit() {
    super.onInit();
    place = explorePlaceById(Get.parameters['id'] ?? '');
    _loadLink();
  }

  Future<void> _loadLink() async {
    final current = place;
    final code = current?.stationCode;
    if (current == null || code == null) {
      return;
    }
    final metro = Get.find<MetroRepository>();
    final stations = await metro.allStations();
    StationModel? station;
    for (final item in stations) {
      if (item.code == code) {
        station = item;
        break;
      }
    }
    if (station == null || station.operationalStatus != 'operational') {
      return;
    }
    final lines = await metro.linesForStation(station.id);
    link = ExploreStationLink(station: station, line: lines.isEmpty ? null : lines.first);
    update();
  }

  void openMap({required bool directions}) {
    showMap.value = true;
    fitBoth.value = directions;
  }
}
