class DataSourceModel {
  const DataSourceModel({
    required this.id,
    required this.key,
    required this.sourceName,
    required this.sourceType,
    required this.verificationStatus,
    this.sourceUrl,
    this.extractedAt,
    this.lastVerifiedAt,
    this.notes,
  });

  final int id;
  final String key;
  final String sourceName;
  final String? sourceUrl;
  final String sourceType;
  final String? extractedAt;
  final String? lastVerifiedAt;
  final String verificationStatus;
  final String? notes;

  factory DataSourceModel.fromMap(Map<String, Object?> row) {
    return DataSourceModel(
      id: row['id'] as int,
      key: row['source_key'] as String,
      sourceName: row['source_name'] as String,
      sourceUrl: row['source_url'] as String?,
      sourceType: row['source_type'] as String,
      extractedAt: row['extracted_at'] as String?,
      lastVerifiedAt: row['last_verified_at'] as String?,
      verificationStatus: row['verification_status'] as String,
      notes: row['notes'] as String?,
    );
  }
}

class DataConflictModel {
  const DataConflictModel({
    required this.id,
    required this.entityType,
    required this.entityKey,
    required this.fieldName,
    required this.status,
    this.valueA,
    this.sourceA,
    this.valueB,
    this.sourceB,
    this.notes,
  });

  final int id;
  final String entityType;
  final String entityKey;
  final String fieldName;
  final String? valueA;
  final String? sourceA;
  final String? valueB;
  final String? sourceB;
  final String status;
  final String? notes;

  factory DataConflictModel.fromMap(Map<String, Object?> row) {
    return DataConflictModel(
      id: row['id'] as int,
      entityType: row['entity_type'] as String,
      entityKey: row['entity_key'] as String,
      fieldName: row['field_name'] as String,
      valueA: row['value_a'] as String?,
      sourceA: row['source_a'] as String?,
      valueB: row['value_b'] as String?,
      sourceB: row['source_b'] as String?,
      status: row['status'] as String,
      notes: row['notes'] as String?,
    );
  }
}

class ImportLogModel {
  const ImportLogModel({
    required this.id,
    required this.level,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String level;
  final String message;
  final String createdAt;

  factory ImportLogModel.fromMap(Map<String, Object?> row) {
    return ImportLogModel(
      id: row['id'] as int,
      level: row['level'] as String,
      message: row['message'] as String,
      createdAt: row['created_at'] as String,
    );
  }
}
