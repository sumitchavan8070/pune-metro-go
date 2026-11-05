class StationFacilityModel {
  const StationFacilityModel({
    required this.id,
    required this.stationId,
    required this.facilityType,
    required this.verificationStatus,
    this.description,
    this.sourceName,
  });

  final int id;
  final int stationId;
  final String facilityType;
  final String? description;
  final String verificationStatus;
  final String? sourceName;

  factory StationFacilityModel.fromMap(Map<String, Object?> row) {
    return StationFacilityModel(
      id: row['id'] as int,
      stationId: row['station_id'] as int,
      facilityType: row['facility_type'] as String,
      description: row['description'] as String?,
      verificationStatus: row['verification_status'] as String,
      sourceName: row['source_name'] as String?,
    );
  }
}
