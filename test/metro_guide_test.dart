import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/data/dataset/dataset_validator.dart';
import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/data/repositories/fare_repository.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/data/services/fare_calculator_service.dart';
import 'package:pune_metro_guide/data/services/import_service.dart';
import 'package:pune_metro_guide/data/services/journey_planner_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> dataset;

  setUpAll(() {
    dataset = jsonDecode(File('assets/data/pune_metro_dataset.json').readAsStringSync())
        as Map<String, dynamic>;
  });

  test('reviewed dataset passes validation', () {
    final result = const DatasetValidator().validate(dataset);
    expect(result.errors, isEmpty, reason: result.errors.join('\n'));
    expect(dataset['fares'], isEmpty);
    expect(dataset['station_timetables'], isEmpty);
  });

  test('import is idempotent and journey times come from the published window', () async {
    final store = MetroStore();
    final importer = ImportService(store, AppLogger());
    final first = await importer.importMap(dataset, origin: 'test');
    final second = await importer.importMap(dataset, origin: 'test');
    expect(first.stations, 72);
    expect(second.stations, 72);

    final metro = MetroRepository(store);
    final stations = await metro.allStations();
    expect(stations.length, 72);
    final byCode = {for (final station in stations) station.code: station};
    final lines = await metro.lines();
    final network = PlannerNetwork(
      stations: stations,
      lines: lines,
      lineStations: await metro.lineStations(),
      interchanges: await metro.allInterchanges(),
      timetables: await TimetableRepository(store).all(),
    );
    const planner = JourneyPlannerService();

    final full = planner.plan(
      origin: byCode['MM-PCMC']!,
      destination: byCode['MM-SWG']!,
      network: network,
      onDate: DateTime(2026, 11, 4),
    );
    expect(full.single.success, isTrue);
    expect(full.single.estimatedMinutes, 34);
    expect(full.single.transferCount, 0);
    expect(full.single.legs.single.stops.map((stop) => stop.station.code), contains('MM-RNG'));
    expect(full.single.legs.single.stops.firstWhere((stop) => stop.station.code == 'MM-RNG').boards, isFalse);

    final partial = planner.plan(
      origin: byCode['MM-PCMC']!,
      destination: byCode['MM-KHA']!,
      network: network,
      onDate: DateTime(2026, 11, 4),
    );
    expect(partial.single.estimatedMinutes, 18);

    final closed = planner.plan(
      origin: byCode['MM-RNG']!,
      destination: byCode['MM-SWG']!,
      network: network,
      onDate: DateTime(2026, 11, 4),
    );
    expect(closed.single.success, isFalse);

    final cross = planner.plan(
      origin: byCode['MM-PCMC']!,
      destination: byCode['MM-RAM']!,
      network: network,
      onDate: DateTime(2026, 11, 4),
    );
    expect(cross.single.success, isTrue);
    expect(cross.single.transferCount, 1);
    expect(cross.single.legs.map((leg) => leg.lineCode), ['PPL', 'AQL']);

    final lineThree = planner.plan(
      origin: byCode['L3-01']!,
      destination: byCode['L3-23']!,
      network: network,
      onDate: DateTime(2026, 11, 4),
    );
    expect(lineThree.single.success, isTrue);
    expect(lineThree.single.estimatedMinutes, isNull);

    final quote = const FareCalculatorService().quote(
      originId: byCode['MM-PCMC']!.id,
      destinationId: byCode['MM-SWG']!.id,
      fares: await FareRepository(store).all(),
    );
    expect(quote.available, isFalse);

    final sndt = await metro.search('s.n.d.t');
    expect(sndt.map((station) => station.code), contains('MM-NAL'));
    expect(byCode['MM-NAL']!.aliasNames, contains('S.N.D.T College'));
    final rto = await metro.search('rto');
    expect(rto.map((station) => station.code), contains('MM-MGP'));
    expect(rto.singleWhere((station) => station.code == 'MM-MGP').aliasNames, contains('R.T.O Pune'));
  });
}
