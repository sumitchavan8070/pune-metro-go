import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/data/repositories/fare_repository.dart';
import 'package:pune_metro_guide/data/services/fare_calculator_service.dart';
import 'package:pune_metro_guide/models/fare_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';

class FareController extends GetxController {
  final origin = Rxn<StationModel>();
  final destination = Rxn<StationModel>();
  final quote = Rxn<FareQuote>();

  Future<void> pick(bool isOrigin) async {
    final selected = await Get.toNamed(AppRoutes.pickStation, arguments: 'pick');
    if (selected is! StationModel) {
      return;
    }
    if (isOrigin) {
      origin.value = selected;
    } else {
      destination.value = selected;
    }
    await calculate();
  }

  void swap() {
    final first = origin.value;
    origin.value = destination.value;
    destination.value = first;
    calculate();
  }

  Future<void> calculate() async {
    final from = origin.value;
    final to = destination.value;
    if (from == null || to == null) {
      quote.value = null;
      return;
    }
    quote.value = Get.find<FareCalculatorService>().quote(
      originId: from.id,
      destinationId: to.id,
      fares: await Get.find<FareRepository>().all(),
    );
  }
}
