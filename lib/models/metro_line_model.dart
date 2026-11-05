class MetroOperatorModel {
  const MetroOperatorModel({
    required this.id,
    required this.name,
    this.website,
    this.description,
  });

  final int id;
  final String name;
  final String? website;
  final String? description;

  factory MetroOperatorModel.fromMap(Map<String, Object?> row) {
    return MetroOperatorModel(
      id: row['id'] as int,
      name: row['name'] as String,
      website: row['website'] as String?,
      description: row['description'] as String?,
    );
  }
}

class MetroLineModel {
  const MetroLineModel({
    required this.id,
    required this.operatorId,
    required this.name,
    required this.code,
    required this.color,
    required this.colorIsOfficial,
    required this.operationalStatus,
    required this.verificationStatus,
    this.originStationId,
    this.destinationStationId,
    this.originName,
    this.destinationName,
    this.routeLengthKm,
    this.lengthVerification,
    this.notes,
    this.operatorName,
    this.sourceName,
  });

  final int id;
  final int operatorId;
  final String name;
  final String code;
  final String color;
  final bool colorIsOfficial;
  final int? originStationId;
  final int? destinationStationId;
  final String? originName;
  final String? destinationName;
  final String operationalStatus;
  final double? routeLengthKm;
  final String? lengthVerification;
  final String verificationStatus;
  final String? notes;
  final String? operatorName;
  final String? sourceName;

  bool get canRide =>
      operationalStatus == 'operational' ||
      operationalStatus == 'partially_operational';

  factory MetroLineModel.fromMap(Map<String, Object?> row) {
    return MetroLineModel(
      id: row['id'] as int,
      operatorId: row['operator_id'] as int,
      name: row['name'] as String,
      code: row['code'] as String,
      color: row['color'] as String,
      colorIsOfficial: (row['color_is_official'] as int? ?? 0) == 1,
      originStationId: row['origin_station_id'] as int?,
      destinationStationId: row['destination_station_id'] as int?,
      originName: row['origin_name'] as String?,
      destinationName: row['destination_name'] as String?,
      operationalStatus: row['operational_status'] as String,
      routeLengthKm: (row['route_length_km'] as num?)?.toDouble(),
      lengthVerification: row['length_verification'] as String?,
      verificationStatus: row['verification_status'] as String,
      notes: row['notes'] as String?,
      operatorName: row['operator_name'] as String?,
      sourceName: row['source_name'] as String?,
    );
  }
}

class LineStationModel {
  const LineStationModel({
    required this.id,
    required this.lineId,
    required this.stationId,
    required this.sequenceNumber,
    required this.direction,
  });

  final int id;
  final int lineId;
  final int stationId;
  final int sequenceNumber;
  final String direction;

  factory LineStationModel.fromMap(Map<String, Object?> row) {
    return LineStationModel(
      id: row['id'] as int,
      lineId: row['line_id'] as int,
      stationId: row['station_id'] as int,
      sequenceNumber: row['sequence_number'] as int,
      direction: row['direction'] as String,
    );
  }
}
