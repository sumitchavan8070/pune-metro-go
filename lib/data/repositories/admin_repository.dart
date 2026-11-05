import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/data_source_model.dart';

class AuditSummary {
  const AuditSummary({
    required this.missingCoordinates,
    required this.duplicateNames,
    required this.sequenceIssues,
    required this.openConflicts,
    required this.fareRows,
    required this.stationCount,
    required this.operationalCount,
  });

  final List<String> missingCoordinates;
  final List<String> duplicateNames;
  final List<String> sequenceIssues;
  final int openConflicts;
  final int fareRows;
  final int stationCount;
  final int operationalCount;
}

class AdminRepository {
  AdminRepository(this._store);

  final MetroStore _store;

  Future<List<DataSourceModel>> sources() async {
    final rows = _store.all('data_sources')..sort((a, b) => (a['source_name'] as String).compareTo(b['source_name'] as String));
    return rows.map(DataSourceModel.fromMap).toList();
  }

  Future<List<DataConflictModel>> conflicts() async {
    final rows = _store.all('data_conflicts')
      ..sort((a, b) {
        final status = (a['status'] as String).compareTo(b['status'] as String);
        if (status != 0) {
          return status;
        }
        return (a['entity_key'] as String).compareTo(b['entity_key'] as String);
      });
    return rows.map(DataConflictModel.fromMap).toList();
  }

  Future<void> markConflictReviewed(int id) async {
    await _store.update('data_conflicts', {'status': 'reviewed'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ImportLogModel>> logs() async {
    final rows = _store.all('import_logs')..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    final limited = rows.length > 40 ? rows.sublist(0, 40) : rows;
    return limited.map(ImportLogModel.fromMap).toList();
  }

  Future<void> correctStationStatus({
    required String stationCode,
    required String operationalStatus,
    required String note,
  }) async {
    final updated = await _store.update(
      'stations',
      {
        'operational_status': operationalStatus,
        'status_verification': 'manual_review',
        'verification_status': 'manual_review',
        'manually_corrected': 1,
        'notes': note,
      },
      where: 'station_code = ?',
      whereArgs: [stationCode],
    );
    await _store.insert('import_logs', {
      'level': updated == 0 ? 'warning' : 'info',
      'message': updated == 0
          ? 'Manual correction found no station $stationCode.'
          : 'Manual status correction saved for $stationCode.',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<AuditSummary> audit() async {
    final missing = _store.all('stations').where((row) => row['latitude'] == null || row['longitude'] == null).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    final grouped = <String, int>{};
    for (final row in _store.all('stations')) {
      final name = row['normalized_name'] as String;
      grouped[name] = (grouped[name] ?? 0) + 1;
    }
    final duplicateNames = grouped.entries.where((entry) => entry.value > 1).map((entry) => entry.key).toList()..sort();
    final issues = <String>[];
    final sequences = <String, List<int>>{};
    for (final row in _store.all('line_stations')) {
      final key = '${row['line_id']}|${row['direction']}';
      sequences.putIfAbsent(key, () => []).add(row['sequence_number'] as int);
    }
    for (final entry in sequences.entries) {
      final numbers = entry.value..sort();
      final count = numbers.length;
      if (numbers.first != 1 || numbers.last != count) {
        final parts = entry.key.split('|');
        issues.add('Line ${parts[0]} ${parts[1]} is not a 1..$count sequence.');
      }
    }
    return AuditSummary(
      missingCoordinates: [
        for (final row in missing) '${row['station_code']}: ${row['name']}',
      ],
      duplicateNames: [
        for (final name in duplicateNames) '$name (${grouped[name]} records, kept separate)',
      ],
      sequenceIssues: issues,
      openConflicts: _store.all('data_conflicts').where((row) => row['status'] == 'open').length,
      fareRows: _store.all('fares').length,
      stationCount: _store.all('stations').length,
      operationalCount: _store.all('stations').where((row) {
        final status = row['operational_status'];
        return status == 'operational' || status == 'reported_open';
      }).length,
    );
  }

  Future<void> addLog(String level, String message) async {
    await _store.insert('import_logs', {
      'level': level,
      'message': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
