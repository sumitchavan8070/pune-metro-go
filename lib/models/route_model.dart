import 'package:pune_metro_guide/models/station_model.dart';

class JourneyStop {
  const JourneyStop({
    required this.station,
    required this.boards,
  });

  final StationModel station;
  final bool boards;
}

class JourneyLeg {
  const JourneyLeg({
    required this.lineName,
    required this.lineCode,
    required this.colorHex,
    required this.stops,
    required this.intervals,
    this.estimatedMinutes,
    this.estimateNote,
  });

  final String lineName;
  final String lineCode;
  final String colorHex;
  final List<JourneyStop> stops;
  final int intervals;
  final int? estimatedMinutes;
  final String? estimateNote;

  int get boardableStops => stops.where((stop) => stop.boards).length;
}

class JourneyPlan {
  const JourneyPlan({
    required this.success,
    required this.legs,
    required this.notices,
    required this.transferCount,
    required this.intervalCount,
    this.errorMessage,
    this.estimatedMinutes,
    this.walkingMinutes,
    this.walkingIncomplete = false,
  });

  const JourneyPlan.failure(String message)
    : success = false,
      errorMessage = message,
      legs = const [],
      notices = const [],
      transferCount = 0,
      intervalCount = 0,
      estimatedMinutes = null,
      walkingMinutes = null,
      walkingIncomplete = false;

  final bool success;
  final String? errorMessage;
  final List<JourneyLeg> legs;
  final List<String> notices;
  final int transferCount;
  final int intervalCount;
  final int? estimatedMinutes;
  final int? walkingMinutes;
  final bool walkingIncomplete;

  Set<int> get stationIds => {
    for (final leg in legs)
      for (final stop in leg.stops) stop.station.id,
  };

  Set<String> get lineCodes => {for (final leg in legs) leg.lineCode};
}
