class TimetableModel {
  const TimetableModel({
    required this.id,
    required this.lineId,
    required this.direction,
    required this.serviceType,
    required this.serviceDayType,
    required this.verificationStatus,
    this.firstTrainTime,
    this.lastTrainTime,
    this.peakHeadwayMinutes,
    this.offPeakHeadwayMinutes,
    this.peakWindows,
    this.offPeakWindows,
    this.endToEndMinutes,
    this.publishedDistanceKm,
    this.validFrom,
    this.validUntil,
    this.notes,
    this.lineName,
    this.sourceName,
    this.sourceUrl,
  });

  final int id;
  final int lineId;
  final String direction;
  final String serviceType;
  final String serviceDayType;
  final String? firstTrainTime;
  final String? lastTrainTime;
  final double? peakHeadwayMinutes;
  final double? offPeakHeadwayMinutes;
  final String? peakWindows;
  final String? offPeakWindows;
  final int? endToEndMinutes;
  final double? publishedDistanceKm;
  final String? validFrom;
  final String? validUntil;
  final String verificationStatus;
  final String? notes;
  final String? lineName;
  final String? sourceName;
  final String? sourceUrl;

  bool isCurrentOn(DateTime day) {
    final from = validFrom == null ? null : DateTime.tryParse(validFrom!);
    final until = validUntil == null ? null : DateTime.tryParse(validUntil!);
    final date = DateTime(day.year, day.month, day.day);
    if (from != null && date.isBefore(DateTime(from.year, from.month, from.day))) {
      return false;
    }
    if (until != null && date.isAfter(DateTime(until.year, until.month, until.day))) {
      return false;
    }
    return true;
  }

  factory TimetableModel.fromMap(Map<String, Object?> row) {
    return TimetableModel(
      id: row['id'] as int,
      lineId: row['line_id'] as int,
      direction: row['direction'] as String,
      serviceType: row['service_type'] as String,
      serviceDayType: row['service_day_type'] as String? ?? 'all_days',
      firstTrainTime: row['first_train_time'] as String?,
      lastTrainTime: row['last_train_time'] as String?,
      peakHeadwayMinutes: (row['peak_headway_minutes'] as num?)?.toDouble(),
      offPeakHeadwayMinutes: (row['off_peak_headway_minutes'] as num?)?.toDouble(),
      peakWindows: row['peak_windows'] as String?,
      offPeakWindows: row['off_peak_windows'] as String?,
      endToEndMinutes: row['end_to_end_minutes'] as int?,
      publishedDistanceKm: (row['published_distance_km'] as num?)?.toDouble(),
      validFrom: row['valid_from'] as String?,
      validUntil: row['valid_until'] as String?,
      verificationStatus: row['verification_status'] as String,
      notes: row['notes'] as String?,
      lineName: row['line_name'] as String?,
      sourceName: row['source_name'] as String?,
      sourceUrl: row['source_url'] as String?,
    );
  }
}

class StationTimetableModel {
  const StationTimetableModel({
    required this.id,
    required this.timetableId,
    required this.stationId,
    required this.departureTime,
    required this.direction,
    required this.serviceDayType,
    required this.verificationStatus,
    this.stationName,
  });

  final int id;
  final int timetableId;
  final int stationId;
  final String departureTime;
  final String direction;
  final String serviceDayType;
  final String verificationStatus;
  final String? stationName;

  factory StationTimetableModel.fromMap(Map<String, Object?> row) {
    return StationTimetableModel(
      id: row['id'] as int,
      timetableId: row['timetable_id'] as int,
      stationId: row['station_id'] as int,
      departureTime: row['departure_time'] as String,
      direction: row['direction'] as String,
      serviceDayType: row['service_day_type'] as String,
      verificationStatus: row['verification_status'] as String,
      stationName: row['station_name'] as String?,
    );
  }
}
