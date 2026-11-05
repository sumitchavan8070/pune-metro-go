class InterchangeModel {
  const InterchangeModel({
    required this.id,
    required this.fromStationId,
    required this.toStationId,
    required this.verificationStatus,
    required this.useForRouting,
    this.interchangeName,
    this.walkingMinutes,
    this.notes,
    this.fromName,
    this.toName,
    this.sourceName,
  });

  final int id;
  final int fromStationId;
  final int toStationId;
  final String? interchangeName;
  final int? walkingMinutes;
  final String? notes;
  final String verificationStatus;
  final bool useForRouting;
  final String? fromName;
  final String? toName;
  final String? sourceName;

  factory InterchangeModel.fromMap(Map<String, Object?> row) {
    return InterchangeModel(
      id: row['id'] as int,
      fromStationId: row['from_station_id'] as int,
      toStationId: row['to_station_id'] as int,
      interchangeName: row['interchange_name'] as String?,
      walkingMinutes: row['walking_minutes'] as int?,
      notes: row['notes'] as String?,
      verificationStatus: row['verification_status'] as String,
      useForRouting: (row['use_for_routing'] as int? ?? 0) == 1,
      fromName: row['from_name'] as String?,
      toName: row['to_name'] as String?,
      sourceName: row['source_name'] as String?,
    );
  }
}
