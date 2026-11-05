class ServiceAlertModel {
  const ServiceAlertModel({
    required this.id,
    required this.title,
    required this.severity,
    required this.verificationStatus,
    this.description,
    this.lineId,
    this.stationId,
    this.startTime,
    this.endTime,
    this.lineName,
    this.stationName,
    this.sourceName,
    this.sourceUrl,
  });

  final int id;
  final String title;
  final String? description;
  final int? lineId;
  final int? stationId;
  final String? startTime;
  final String? endTime;
  final String severity;
  final String verificationStatus;
  final String? lineName;
  final String? stationName;
  final String? sourceName;
  final String? sourceUrl;

  bool isActiveAt(DateTime moment) {
    final start = startTime == null ? null : DateTime.tryParse(startTime!);
    final end = endTime == null ? null : DateTime.tryParse(endTime!);
    if (start != null && moment.isBefore(start)) {
      return false;
    }
    if (end != null && moment.isAfter(end)) {
      return false;
    }
    return true;
  }

  factory ServiceAlertModel.fromMap(Map<String, Object?> row) {
    return ServiceAlertModel(
      id: row['id'] as int,
      title: row['title'] as String,
      description: row['description'] as String?,
      lineId: row['line_id'] as int?,
      stationId: row['station_id'] as int?,
      startTime: row['start_time'] as String?,
      endTime: row['end_time'] as String?,
      severity: row['severity'] as String,
      verificationStatus: row['verification_status'] as String,
      lineName: row['line_name'] as String?,
      stationName: row['station_name'] as String?,
      sourceName: row['source_name'] as String?,
      sourceUrl: row['source_url'] as String?,
    );
  }
}
