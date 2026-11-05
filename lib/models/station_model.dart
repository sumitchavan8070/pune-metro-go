class StationModel {
  const StationModel({
    required this.id,
    required this.code,
    required this.name,
    required this.normalizedName,
    required this.operationalStatus,
    required this.statusVerification,
    required this.verificationStatus,
    required this.isInterchange,
    this.latitude,
    this.longitude,
    this.coordinateVerification,
    this.coordinateNotes,
    this.address,
    this.description,
    this.openingDate,
    this.notes,
    this.sourceId,
    this.sourceName,
    this.sourceUrl,
    this.manuallyCorrected = false,
    this.lineNames = const [],
    this.aliasNames = const [],
  });

  final int id;
  final String code;
  final String name;
  final String normalizedName;
  final double? latitude;
  final double? longitude;
  final String? coordinateVerification;
  final String? coordinateNotes;
  final String? address;
  final String? description;
  final String operationalStatus;
  final String statusVerification;
  final bool isInterchange;
  final String? openingDate;
  final String verificationStatus;
  final String? notes;
  final int? sourceId;
  final String? sourceName;
  final String? sourceUrl;
  final bool manuallyCorrected;
  final List<String> lineNames;
  final List<String> aliasNames;

  bool get isBoardable =>
      operationalStatus == 'operational' || operationalStatus == 'reported_open';

  bool get hasCoordinates => latitude != null && longitude != null;

  StationModel copyWith({List<String>? lineNames, List<String>? aliasNames, bool? isInterchange}) {
    return StationModel(
      id: id,
      code: code,
      name: name,
      normalizedName: normalizedName,
      operationalStatus: operationalStatus,
      statusVerification: statusVerification,
      verificationStatus: verificationStatus,
      isInterchange: isInterchange ?? this.isInterchange,
      latitude: latitude,
      longitude: longitude,
      coordinateVerification: coordinateVerification,
      coordinateNotes: coordinateNotes,
      address: address,
      description: description,
      openingDate: openingDate,
      notes: notes,
      sourceId: sourceId,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      manuallyCorrected: manuallyCorrected,
      lineNames: lineNames ?? this.lineNames,
      aliasNames: aliasNames ?? this.aliasNames,
    );
  }

  factory StationModel.fromMap(Map<String, Object?> row) {
    return StationModel(
      id: row['id'] as int,
      code: row['station_code'] as String,
      name: row['name'] as String,
      normalizedName: row['normalized_name'] as String,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      coordinateVerification: row['coordinate_verification'] as String?,
      coordinateNotes: row['coordinate_notes'] as String?,
      address: row['address'] as String?,
      description: row['description'] as String?,
      operationalStatus: row['operational_status'] as String,
      statusVerification: row['status_verification'] as String? ?? 'unavailable',
      isInterchange: (row['is_interchange'] as int? ?? 0) == 1,
      openingDate: row['opening_date'] as String?,
      verificationStatus: row['verification_status'] as String,
      notes: row['notes'] as String?,
      sourceId: row['source_id'] as int?,
      sourceName: row['source_name'] as String?,
      sourceUrl: row['source_url'] as String?,
      manuallyCorrected: (row['manually_corrected'] as int? ?? 0) == 1,
    );
  }
}

class StationAliasModel {
  const StationAliasModel({
    required this.alias,
    this.notes,
    this.sourceName,
  });

  final String alias;
  final String? notes;
  final String? sourceName;

  factory StationAliasModel.fromMap(Map<String, Object?> row) {
    return StationAliasModel(
      alias: row['alias'] as String,
      notes: row['notes'] as String?,
      sourceName: row['source_name'] as String?,
    );
  }
}
