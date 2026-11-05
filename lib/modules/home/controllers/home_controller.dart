import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/data/repositories/alert_repository.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/services/location_service.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/service_alert_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
class NearbyStation {
  const NearbyStation(this.station, this.metres);

  final StationModel station;
  final double metres;
}

class HomeController extends GetxController {
  /// City centre used only to decide whether nearby stations are relevant.
  static const puneLatitude = 18.5204;
  static const puneLongitude = 73.8567;
  static const nearbyRadiusMetres = 100000.0;

  final lines = <MetroLineModel>[].obs;
  final alerts = <ServiceAlertModel>[].obs;
  final results = <StationModel>[].obs;
  final nearby = <NearbyStation>[].obs;
  final query = ''.obs;
  final loading = true.obs;
  final nearbyLoading = false.obs;
  final nearbyMessage = RxnString();
  final extractedAt = RxnString();
  final importedAt = RxnString();
  final operationalCounts = <int, int>{}.obs;
  final error = RxnString();
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final metro = Get.find<MetroRepository>();
      lines.assignAll(await metro.lines());
      final counts = <int, int>{};
      for (final line in lines) {
        final stations = await metro.stationsOnLine(line.id);
        counts[line.id] = stations
            .where((station) => station.operationalStatus == 'operational')
            .length;
      }
      operationalCounts.assignAll(counts);
      alerts.assignAll(await Get.find<AlertRepository>().active());
      final meta = await metro.meta();
      extractedAt.value = meta['extracted_at'];
      importedAt.value = meta['imported_at'];
    } catch (caught) {
      error.value = 'Home data could not be loaded. $caught';
    } finally {
      loading.value = false;
    }
    if (error.value == null) {
      await findNearby();
    }
  }

  void onSearch(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () async {
      if (value.trim().length < 2) {
        results.clear();
        return;
      }
      results.assignAll(await Get.find<MetroRepository>().search(value));
    });
  }

  Future<void> findNearby() async {
    nearbyLoading.value = true;
    if (nearby.isEmpty) {
      nearbyMessage.value = 'Finding stations near you.';
    }
    try {
      final stations = await Get.find<MetroRepository>().allStations();
      final last = await Get.find<LocationService>().lastKnown();
      if (last != null) {
        if (_farFromPune(last)) {
          nearby.clear();
        } else {
          _showNearest(stations, last);
          nearbyMessage.value = null;
        }
      }
      final outcome = await Get.find<LocationService>().currentFix();
      if (!outcome.granted) {
        if (last != null && _farFromPune(last)) {
          nearby.clear();
          nearbyMessage.value = _farMessage;
        } else if (nearby.isEmpty) {
          nearbyMessage.value = outcome.message;
        }
        return;
      }
      if (_farFromPune(outcome.fix!)) {
        nearby.clear();
        nearbyMessage.value = _farMessage;
        return;
      }
      _showNearest(stations, outcome.fix!);
      final missing = stations.where((station) => !station.hasCoordinates).length;
      nearbyMessage.value = missing == 0
          ? null
          : '$missing stations have no published coordinate, so they are left out of this list.';
    } finally {
      nearbyLoading.value = false;
    }
  }

  static const _farMessage =
      'You are more than 100 km from Pune, so nearby stations stay hidden.';

  bool _farFromPune(LocationFix fix) {
    return haversineMetres(fix.latitude, fix.longitude, puneLatitude, puneLongitude) >=
        nearbyRadiusMetres;
  }

  void _showNearest(List<StationModel> stations, LocationFix fix) {
    final located = <NearbyStation>[
      for (final station in stations)
        if (station.hasCoordinates)
          NearbyStation(
            station,
            haversineMetres(fix.latitude, fix.longitude, station.latitude!, station.longitude!),
          ),
    ]..sort((a, b) => a.metres.compareTo(b.metres));
    nearby.assignAll(located.take(6));
  }
}
