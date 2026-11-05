import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/data/repositories/fare_repository.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/data/services/fare_calculator_service.dart';
import 'package:pune_metro_guide/data/services/journey_planner_service.dart';
import 'package:pune_metro_guide/models/fare_model.dart';
import 'package:pune_metro_guide/models/route_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/modules/shell/controllers/shell_controller.dart';

class JourneyPlannerController extends GetxController {
  final origin = Rxn<StationModel>();
  final destination = Rxn<StationModel>();
  final plans = <JourneyPlan>[].obs;
  final quote = Rxn<FareQuote>();
  final planning = false.obs;
  final error = RxnString();

  Future<void> pickOrigin() => _pick(true);

  Future<void> pickDestination() => _pick(false);

  Future<void> _pick(bool isOrigin) async {
    final selected = await Get.toNamed(AppRoutes.pickStation, arguments: 'pick');
    if (selected is StationModel) {
      if (isOrigin) {
        origin.value = selected;
      } else {
        destination.value = selected;
      }
      plans.clear();
      quote.value = null;
    }
  }

  void swap() {
    final first = origin.value;
    origin.value = destination.value;
    destination.value = first;
    plans.clear();
    quote.value = null;
  }

  Future<void> prefill(int? originId, int? destinationId) async {
    final stations = await Get.find<MetroRepository>().allStations();
    if (originId != null) {
      origin.value = stations.cast<StationModel?>().firstWhere(
        (station) => station?.id == originId,
        orElse: () => null,
      );
    }
    if (destinationId != null) {
      destination.value = stations.cast<StationModel?>().firstWhere(
        (station) => station?.id == destinationId,
        orElse: () => null,
      );
    }
  }

  Future<void> plan() async {
    final from = origin.value;
    final to = destination.value;
    if (from == null || to == null) {
      error.value = 'Choose both stations.';
      plans.clear();
      return;
    }
    planning.value = true;
    error.value = null;
    final metro = Get.find<MetroRepository>();
    final network = PlannerNetwork(
      stations: await metro.allStations(),
      lines: await metro.lines(),
      lineStations: await metro.lineStations(),
      interchanges: await metro.allInterchanges(),
      timetables: await Get.find<TimetableRepository>().all(),
    );
    final results = Get.find<JourneyPlannerService>().plan(
      origin: from,
      destination: to,
      network: network,
    );
    plans.assignAll(results);
    quote.value = Get.find<FareCalculatorService>().quote(
      originId: from.id,
      destinationId: to.id,
      fares: await Get.find<FareRepository>().all(),
    );
    planning.value = false;
  }

  void showOnMap() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().select(2);
    }
  }
}
