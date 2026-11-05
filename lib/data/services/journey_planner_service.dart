import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';
import 'package:pune_metro_guide/models/interchange_model.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/route_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class PlannerNetwork {
  const PlannerNetwork({
    required this.stations,
    required this.lines,
    required this.lineStations,
    required this.interchanges,
    required this.timetables,
  });

  final List<StationModel> stations;
  final List<MetroLineModel> lines;
  final List<LineStationModel> lineStations;
  final List<InterchangeModel> interchanges;
  final List<TimetableModel> timetables;
}

class JourneyPlannerService {
  const JourneyPlannerService();

  List<JourneyPlan> plan({
    required StationModel origin,
    required StationModel destination,
    required PlannerNetwork network,
    DateTime? onDate,
  }) {
    if (origin.id == destination.id) {
      return const [JourneyPlan.failure('Choose two different stations.')];
    }
    if (!origin.isBoardable) {
      return [
        JourneyPlan.failure(_unavailable(origin)),
      ];
    }
    if (!destination.isBoardable) {
      return [
        JourneyPlan.failure(_unavailable(destination)),
      ];
    }

    final day = onDate ?? DateTime.now();
    final stations = {for (final station in network.stations) station.id: station};
    final lines = {for (final line in network.lines) line.id: line};
    final rideable = network.lines.where((line) => line.canRide).map((line) => line.id).toSet();
    final forward = _forwardLinks(network, lines);
    final neighbors = <int, Map<int, List<int>>>{};
    final lineIntervals = <int, int>{};
    final orderOnLine = <int, Map<int, int>>{};

    for (final entry in forward.entries) {
      final rows = [...entry.value]..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
      lineIntervals[entry.key] = rows.length - 1;
      orderOnLine[entry.key] = {
        for (final row in rows) row.stationId: row.sequenceNumber,
      };
      for (var index = 0; index < rows.length - 1; index++) {
        _link(neighbors, rows[index].stationId, entry.key, rows[index + 1].stationId);
        _link(neighbors, rows[index + 1].stationId, entry.key, rows[index].stationId);
      }
    }

    final walks = <int, List<InterchangeModel>>{};
    for (final interchange in network.interchanges.where((item) => item.useForRouting)) {
      walks.putIfAbsent(interchange.fromStationId, () => []).add(interchange);
      walks.putIfAbsent(interchange.toStationId, () => []).add(interchange);
    }

    final currentTimetables = <int, TimetableModel?>{};
    for (final line in network.lines) {
      final rows = network.timetables
          .where(
            (item) =>
                item.lineId == line.id &&
                item.serviceType == 'regular' &&
                item.isCurrentOn(day),
          )
          .toList();
      currentTimetables[line.id] = rows.length == 1 ? rows.first : null;
    }

    final found = _search(
      origin: origin,
      destination: destination,
      stations: stations,
      lines: lines,
      rideable: rideable,
      neighbors: neighbors,
      walks: walks,
    );

    if (found.isEmpty) {
      return const [
        JourneyPlan.failure(
          'No passenger route is available with the stations that are open in the stored data.',
        ),
      ];
    }

    return found
        .map(
          (path) => _materialise(
            path: path,
            stations: stations,
            lines: lines,
            lineIntervals: lineIntervals,
            orderOnLine: orderOnLine,
            timetables: currentTimetables,
          ),
        )
        .toList();
  }

  String _unavailable(StationModel station) {
    final label = operationalStatus(station.operationalStatus).label;
    return '${station.name} is $label, so it cannot be used as a boarding station.';
  }

  Map<int, List<LineStationModel>> _forwardLinks(
    PlannerNetwork network,
    Map<int, MetroLineModel> lines,
  ) {
    final grouped = <int, Map<String, List<LineStationModel>>>{};
    for (final link in network.lineStations) {
      grouped.putIfAbsent(link.lineId, () => {});
      grouped[link.lineId]!.putIfAbsent(link.direction, () => []).add(link);
    }
    final forward = <int, List<LineStationModel>>{};
    for (final entry in grouped.entries) {
      final line = lines[entry.key];
      if (line == null || !line.canRide || line.originStationId == null) {
        continue;
      }
      for (final rows in entry.value.values) {
        final first = rows.where((row) => row.sequenceNumber == 1).toList();
        if (first.length == 1 && first.first.stationId == line.originStationId) {
          forward[entry.key] = rows;
          break;
        }
      }
    }
    return forward;
  }

  void _link(Map<int, Map<int, List<int>>> neighbors, int from, int lineId, int to) {
    neighbors.putIfAbsent(from, () => {});
    neighbors[from]!.putIfAbsent(lineId, () => []).add(to);
  }

  List<_Path> _search({
    required StationModel origin,
    required StationModel destination,
    required Map<int, StationModel> stations,
    required Map<int, MetroLineModel> lines,
    required Set<int> rideable,
    required Map<int, Map<int, List<int>>> neighbors,
    required Map<int, List<InterchangeModel>> walks,
  }) {
    final queue = <_State>[
      _State(
        stationId: origin.id,
        lineId: -1,
        transfers: 0,
        intervals: 0,
        hops: const [],
      ),
    ];
    final best = <String, int>{};
    final results = <_Path>[];
    final signatures = <String>{};
    var guard = 0;

    while (queue.isNotEmpty && results.length < 2 && guard < 5000) {
      guard++;
      queue.sort();
      final state = queue.removeAt(0);
      final key = '${state.stationId}:${state.lineId}';
      final score = state.transfers * 1000 + state.intervals;
      final known = best[key];
      if (known != null && known <= score) {
        continue;
      }
      best[key] = score;

      if (state.stationId == destination.id && state.lineId != -1) {
        final signature = state.signature;
        if (signatures.add(signature)) {
          results.add(_Path(state.hops, state.transfers, state.intervals));
        }
        continue;
      }

      if (state.lineId == -1) {
        for (final lineId in neighbors[state.stationId]?.keys ?? const <int>[]) {
          if (!rideable.contains(lineId)) {
            continue;
          }
          queue.add(
            state.copyWith(lineId: lineId, signature: '${lines[lineId]?.code ?? lineId}'),
          );
        }
        continue;
      }

      for (final next in neighbors[state.stationId]?[state.lineId] ?? const <int>[]) {
        queue.add(
          state.copyWith(
            stationId: next,
            intervals: state.intervals + 1,
            hops: [
              ...state.hops,
              _Ride(state.lineId, state.stationId, next),
            ],
          ),
        );
      }

      final here = stations[state.stationId];
      if (here != null && here.isBoardable && state.hops.isNotEmpty) {
        for (final lineId in neighbors[state.stationId]?.keys ?? const <int>[]) {
          if (lineId == state.lineId || !rideable.contains(lineId)) {
            continue;
          }
          queue.add(
            state.copyWith(
              lineId: lineId,
              transfers: state.transfers + 1,
              hops: [
                ...state.hops,
                _SameStation(state.stationId, state.lineId, lineId),
              ],
              signature: '${state.signature}>${lines[lineId]?.code ?? lineId}',
            ),
          );
        }
        for (final interchange in walks[state.stationId] ?? const <InterchangeModel>[]) {
          final other = interchange.fromStationId == state.stationId
              ? interchange.toStationId
              : interchange.fromStationId;
          final otherStation = stations[other];
          if (otherStation == null || !otherStation.isBoardable) {
            continue;
          }
          queue.add(
            _State(
              stationId: other,
              lineId: -1,
              transfers: state.transfers + 1,
              intervals: state.intervals,
              hops: [
                ...state.hops,
                _Walk(
                  state.stationId,
                  other,
                  interchange.walkingMinutes,
                  interchange.interchangeName ?? 'Interchange',
                ),
              ],
              signature: state.signature,
            ),
          );
        }
      }
    }
    return results;
  }

  JourneyPlan _materialise({
    required _Path path,
    required Map<int, StationModel> stations,
    required Map<int, MetroLineModel> lines,
    required Map<int, int> lineIntervals,
    required Map<int, Map<int, int>> orderOnLine,
    required Map<int, TimetableModel?> timetables,
  }) {
    final legs = <JourneyLeg>[];
    final notices = <String>[
      'Scheduled information only. This is not live train tracking.',
    ];
    var walking = 0;
    var walkingIncomplete = false;
    final rides = <_Ride>[];

    void flush() {
      if (rides.isEmpty) {
        return;
      }
      final line = lines[rides.first.lineId]!;
      final ids = <int>[rides.first.fromId, for (final ride in rides) ride.toId];
      final stops = [
        for (final id in ids)
          JourneyStop(
            station: stations[id]!,
            boards: stations[id]!.isBoardable,
          ),
      ];
      final intervals = rides.length;
      final total = lineIntervals[line.id] ?? 0;
      final table = timetables[line.id];
      int? minutes;
      String? note;
      if (table?.endToEndMinutes != null && total > 0) {
        minutes = (table!.endToEndMinutes! * intervals / total).round();
        note = AppConstants.estimateMethod;
      } else {
        note = '${line.name} has no published end-to-end time, so this leg is not given a duration.';
      }
      legs.add(
        JourneyLeg(
          lineName: line.name,
          lineCode: line.code,
          colorHex: line.color,
          stops: stops,
          intervals: intervals,
          estimatedMinutes: minutes,
          estimateNote: note,
        ),
      );
      rides.clear();
    }

    for (final hop in path.hops) {
      if (hop is _Ride) {
        rides.add(hop);
        continue;
      }
      flush();
      if (hop is _SameStation) {
        notices.add(
          'Change at ${stations[hop.stationId]?.name ?? 'the interchange'}. Transfer time inside the station was not published and is not included.',
        );
      } else if (hop is _Walk) {
        if (hop.minutes == null) {
          walkingIncomplete = true;
          notices.add(
            '${hop.name}: walking time between ${stations[hop.fromId]?.name ?? 'one station'} and ${stations[hop.toId]?.name ?? 'the other'} was not published and is not included.',
          );
        } else {
          walking += hop.minutes!;
        }
      }
    }
    flush();

    final reported = <String>{};
    for (final leg in legs) {
      for (final stop in leg.stops) {
        if (stop.station.operationalStatus == 'reported_open' ||
            stop.station.operationalStatus == 'reported_closed') {
          reported.add(stop.station.name);
        }
        if (!stop.boards && stop != leg.stops.first && stop != leg.stops.last) {
          notices.add(
            '${stop.station.name} is ${operationalStatus(stop.station.operationalStatus).label}. It stays in the sequence. Whether trains pass it without stopping was not published.',
          );
        }
      }
    }
    if (reported.isNotEmpty) {
      notices.add(
        'Opening status for ${reported.join(', ')} comes from a secondary report, not from an operator station-status table.',
      );
    }
    if (legs.any((leg) => leg.estimatedMinutes != null)) {
      notices.add(AppConstants.estimateMethod);
    }

    final minutes = legs.every((leg) => leg.estimatedMinutes != null)
        ? legs.fold<int>(0, (sum, leg) => sum + (leg.estimatedMinutes ?? 0)) +
            (walkingIncomplete ? 0 : walking)
        : null;
    if (minutes == null) {
      notices.add('A complete journey time is not shown because at least one leg has no published duration.');
    }

    return JourneyPlan(
      success: true,
      legs: legs,
      notices: notices.toSet().toList(),
      transferCount: path.transfers,
      intervalCount: path.intervals,
      estimatedMinutes: minutes,
      walkingMinutes: walking == 0 ? null : walking,
      walkingIncomplete: walkingIncomplete,
    );
  }
}

class _Path {
  const _Path(this.hops, this.transfers, this.intervals);

  final List<_Hop> hops;
  final int transfers;
  final int intervals;
}

class _State implements Comparable<_State> {
  const _State({
    required this.stationId,
    required this.lineId,
    required this.transfers,
    required this.intervals,
    required this.hops,
    this.signature = '',
  });

  final int stationId;
  final int lineId;
  final int transfers;
  final int intervals;
  final List<_Hop> hops;
  final String signature;

  _State copyWith({
    int? stationId,
    int? lineId,
    int? transfers,
    int? intervals,
    List<_Hop>? hops,
    String? signature,
  }) {
    return _State(
      stationId: stationId ?? this.stationId,
      lineId: lineId ?? this.lineId,
      transfers: transfers ?? this.transfers,
      intervals: intervals ?? this.intervals,
      hops: hops ?? this.hops,
      signature: signature ?? this.signature,
    );
  }

  @override
  int compareTo(_State other) {
    final byTransfer = transfers.compareTo(other.transfers);
    if (byTransfer != 0) {
      return byTransfer;
    }
    return intervals.compareTo(other.intervals);
  }
}

sealed class _Hop {}

class _Ride extends _Hop {
  _Ride(this.lineId, this.fromId, this.toId);

  final int lineId;
  final int fromId;
  final int toId;
}

class _SameStation extends _Hop {
  _SameStation(this.stationId, this.fromLine, this.toLine);

  final int stationId;
  final int fromLine;
  final int toLine;
}

class _Walk extends _Hop {
  _Walk(this.fromId, this.toId, this.minutes, this.name);

  final int fromId;
  final int toId;
  final int? minutes;
  final String name;
}
