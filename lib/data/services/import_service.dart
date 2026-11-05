import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pune_metro_guide/app/constants/app_constants.dart';
import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/data/dataset/dataset_validator.dart';
import 'package:pune_metro_guide/data/store/metro_store.dart';

class ImportException implements Exception {
  ImportException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join('\n');
}

class ImportReport {
  ImportReport({
    required this.datasetVersion,
    required this.origin,
    required this.operators,
    required this.lines,
    required this.stations,
    required this.operational,
    required this.notInService,
    required this.timetables,
    required this.fares,
    required this.conflicts,
    required this.skippedManual,
  });

  final String datasetVersion;
  final String origin;
  final int operators;
  final int lines;
  final int stations;
  final int operational;
  final int notInService;
  final int timetables;
  final int fares;
  final int conflicts;
  final int skippedManual;
}

class ImportService {
  ImportService(this._store, this._logger);

  final MetroStore _store;
  final AppLogger _logger;
  final DatasetValidator _validator = const DatasetValidator();

  Future<void> ensureImported() async {
    await _store.hydrate();
    final asset = await loadAsset();
    final current = await _store.query(
      'meta',
      where: 'key = ?',
      whereArgs: ['dataset_version'],
    );
    final version = asset['dataset_version'] as String;
    if (current.isEmpty || current.first['value'] != version) {
      await importMap(asset, origin: 'bundled asset');
    }
  }

  Future<Map<String, dynamic>> loadAsset() async {
    final raw = await rootBundle.loadString(AppConstants.datasetAsset);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<ImportReport> importJson(String raw, {required String origin}) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw ImportException(['Dataset must be a JSON object.']);
    }
    return importMap(decoded, origin: origin);
  }

  Future<ImportReport> importMap(
    Map<String, dynamic> json, {
    required String origin,
  }) async {
    final validation = _validator.validate(json);
    if (!validation.isValid) {
      await _log('error', 'Import rejected: ${validation.errors.join(' ')}');
      throw ImportException(validation.errors);
    }

    var skippedManual = 0;
    try {
      await _store.runBatch(() async {
        final sources = await _upsertSources(_store, _rows(json['sources']));
        final operators = await _upsertOperators(_store, _rows(json['operators']));
        final stationIds = <String, int>{};
        for (final row in _rows(json['stations'])) {
          final result = await _upsertStation(_store, row, sources);
          stationIds[row['code'] as String] = result.id;
          if (result.skipped) {
            skippedManual++;
          }
        }
        final lineIds = <String, int>{};
        for (final row in _rows(json['lines'])) {
          lineIds[row['code'] as String] = await _upsertLine(
            _store,
            row,
            operators,
            stationIds,
            sources,
          );
        }
        await _store.delete('line_stations');
        for (final row in _rows(json['line_stations'])) {
          await _store.insert('line_stations', {
            'line_id': lineIds[row['line_code']],
            'station_id': stationIds[row['station_code']],
            'sequence_number': row['sequence_number'],
            'direction': row['direction'],
          });
        }
        await _replaceAliases(_store, _rows(json['stations']), stationIds, sources);
        await _replaceSimpleChildren(_store, json, lineIds, stationIds, sources);
        await _upsertConflicts(_store, _rows(json['conflicts']));
        await _markInterchanges(_store);
        final now = DateTime.now().toUtc().toIso8601String();
        await _meta(_store, 'dataset_version', json['dataset_version'] as String);
        await _meta(_store, 'extracted_at', json['extracted_at'] as String);
        await _meta(_store, 'imported_at', now);
        await _meta(_store, 'import_origin', origin);
        await _store.insert('import_logs', {
          'level': 'info',
          'message': 'Imported ${json['dataset_version']} from $origin.',
          'created_at': now,
        });
      });
    } catch (error, stackTrace) {
      _logger.error('Firebase import failed', error: error, stackTrace: stackTrace);
      rethrow;
    }

    final stations = _rows(json['stations']);
    final report = ImportReport(
      datasetVersion: json['dataset_version'] as String,
      origin: origin,
      operators: _rows(json['operators']).length,
      lines: _rows(json['lines']).length,
      stations: stations.length,
      operational: stations
          .where((row) => row['operational_status'] == 'operational' || row['operational_status'] == 'reported_open')
          .length,
      notInService: stations
          .where((row) => row['operational_status'] != 'operational' && row['operational_status'] != 'reported_open')
          .length,
      timetables: _rows(json['timetables']).length,
      fares: _rows(json['fares']).length,
      conflicts: _rows(json['conflicts']).length,
      skippedManual: skippedManual,
    );
    _logger.info(
      'Import ${report.datasetVersion}: ${report.stations} stations, ${report.conflicts} conflicts.',
    );
    return report;
  }

  Future<void> _log(String level, String message) async {
    _logger.error(message);
    await _store.insert('import_logs', {
      'level': level,
      'message': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> _rows(Object? value) {
    if (value is! List) {
      return [];
    }
    return value.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  Future<Map<String, int>> _upsertSources(MetroStore store, List<Map<String, dynamic>> rows) async {
    final ids = <String, int>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final data = {
        'source_key': key,
        'source_name': row['source_name'],
        'source_url': row['source_url'],
        'source_type': row['source_type'],
        'extracted_at': row['extracted_at'],
        'last_verified_at': row['last_verified_at'],
        'verification_status': row['verification_status'],
        'notes': row['notes'],
      };
      ids[key] = await _upsertBy(store, 'data_sources', 'source_key', key, data);
    }
    return ids;
  }

  Future<Map<String, int>> _upsertOperators(MetroStore store, List<Map<String, dynamic>> rows) async {
    final ids = <String, int>{};
    for (final row in rows) {
      final key = row['key'] as String;
      ids[key] = await _upsertBy(store, 'metro_operators', 'operator_key', key, {
        'operator_key': key,
        'name': row['name'],
        'website': row['website'],
        'description': row['description'],
      });
    }
    return ids;
  }

  Future<_StationWrite> _upsertStation(
    MetroStore store,
    Map<String, dynamic> row,
    Map<String, int> sources,
  ) async {
    final code = row['code'] as String;
    final existing = await store.query(
      'stations',
      where: 'station_code = ?',
      whereArgs: [code],
    );
    final data = {
      'station_code': code,
      'name': row['name'],
      'normalized_name': normalizeStationName(row['name'] as String),
      'latitude': row['latitude'],
      'longitude': row['longitude'],
      'coordinate_verification': row['coordinate_verification'],
      'coordinate_notes': row['coordinate_notes'],
      'address': row['address'],
      'description': row['description'],
      'operational_status': row['operational_status'],
      'status_verification': row['status_verification'],
      'is_interchange': row['is_interchange'] == true ? 1 : 0,
      'opening_date': row['opening_date'],
      'verification_status': row['verification_status'],
      'source_id': sources[row['source_key']],
      'notes': row['notes'],
    };
    if (existing.isEmpty) {
      final id = await store.insert('stations', data);
      return _StationWrite(id, false);
    }
    final current = existing.first;
    final id = current['id'] as int;
    if ((current['manually_corrected'] as int? ?? 0) == 1) {
      return _StationWrite(id, true);
    }
    final incomingRank = _rank(row['verification_status'] as String);
    final currentRank = _rank(current['verification_status'] as String);
    if (incomingRank < currentRank && current['name'] != row['name']) {
      await store.insert('import_logs', {
        'level': 'warning',
        'message': 'Kept $code because the stored verification outranks the incoming dataset.',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return _StationWrite(id, false);
    }
    await store.update('stations', data, where: 'id = ?', whereArgs: [id]);
    return _StationWrite(id, false);
  }

  Future<int> _upsertLine(
    MetroStore store,
    Map<String, dynamic> row,
    Map<String, int> operators,
    Map<String, int> stations,
    Map<String, int> sources,
  ) async {
    final code = row['code'] as String;
    final data = {
      'operator_id': operators[row['operator_key']],
      'name': row['name'],
      'code': code,
      'color': row['color'],
      'color_is_official': row['color_is_official'] == true ? 1 : 0,
      'origin_station_id': stations[row['origin_station_code']],
      'destination_station_id': stations[row['destination_station_code']],
      'operational_status': row['operational_status'],
      'route_length_km': row['route_length_km'],
      'length_verification': row['length_verification'],
      'verification_status': row['verification_status'],
      'source_id': sources[row['source_key']],
      'notes': row['notes'],
    };
    return _upsertBy(store, 'metro_lines', 'code', code, data);
  }

  Future<void> _replaceAliases(
    MetroStore store,
    List<Map<String, dynamic>> stations,
    Map<String, int> stationIds,
    Map<String, int> sources,
  ) async {
    for (final station in stations) {
      final id = stationIds[station['code']];
      final manual = await store.query(
        'stations',
        columns: ['manually_corrected'],
        where: 'id = ?',
        whereArgs: [id],
      );
      if ((manual.first['manually_corrected'] as int? ?? 0) == 1) {
        continue;
      }
      await store.delete('station_aliases', where: 'station_id = ?', whereArgs: [id]);
      final aliases = station['aliases'];
      if (aliases is! List) {
        continue;
      }
      for (final alias in aliases) {
        final row = Map<String, dynamic>.from(alias as Map);
        final name = row['name'] as String;
        await store.insert('station_aliases', {
          'station_id': id,
          'alias': name,
          'normalized_alias': normalizeStationName(name),
          'source_id': sources[row['source_key']],
          'notes': row['notes'],
        });
      }
    }
  }

  Future<void> _replaceSimpleChildren(
    MetroStore store,
    Map<String, dynamic> json,
    Map<String, int> lineIds,
    Map<String, int> stationIds,
    Map<String, int> sources,
  ) async {
    await store.delete('timetables');
    for (final row in _rows(json['timetables'])) {
      await store.insert('timetables', {
        'line_id': lineIds[row['line_code']],
        'direction': row['direction'],
        'service_type': row['service_type'],
        'service_day_type': row['service_day_type'],
        'first_train_time': row['first_train_time'],
        'last_train_time': row['last_train_time'],
        'peak_headway_minutes': row['peak_headway_minutes'],
        'off_peak_headway_minutes': row['off_peak_headway_minutes'],
        'peak_windows': row['peak_windows'],
        'off_peak_windows': row['off_peak_windows'],
        'end_to_end_minutes': row['end_to_end_minutes'],
        'published_distance_km': row['published_distance_km'],
        'valid_from': row['valid_from'],
        'valid_until': row['valid_until'],
        'verification_status': row['verification_status'],
        'source_id': sources[row['source_key']],
        'notes': row['notes'],
      });
    }
    await store.delete('fares');
    for (final row in _rows(json['fares'])) {
      await store.insert('fares', {
        'line_id': lineIds[row['line_code']],
        'origin_station_id': stationIds[row['origin_station_code']],
        'destination_station_id': stationIds[row['destination_station_code']],
        'amount': row['amount'],
        'currency': row['currency'],
        'valid_from': row['valid_from'],
        'valid_until': row['valid_until'],
        'source_id': sources[row['source_key']],
        'verification_status': row['verification_status'],
      });
    }
    await store.delete('station_facilities');
    await store.delete('interchanges');
    for (final row in _rows(json['interchanges'])) {
      await store.insert('interchanges', {
        'from_station_id': stationIds[row['from_station_code']],
        'to_station_id': stationIds[row['to_station_code']],
        'interchange_name': row['interchange_name'],
        'walking_minutes': row['walking_minutes'],
        'notes': row['notes'],
        'verification_status': row['verification_status'],
        'use_for_routing': row['use_for_routing'] == true ? 1 : 0,
        'source_id': sources[row['source_key']],
      });
    }
    await store.delete('service_alerts');
    for (final row in _rows(json['alerts'])) {
      await store.insert('service_alerts', {
        'title': row['title'],
        'description': row['description'],
        'line_id': lineIds[row['line_code']],
        'station_id': stationIds[row['station_code']],
        'start_time': row['start_time'],
        'end_time': row['end_time'],
        'severity': row['severity'],
        'source_id': sources[row['source_key']],
        'verification_status': row['verification_status'],
      });
    }
  }

  Future<void> _upsertConflicts(MetroStore store, List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final existing = await store.query(
        'data_conflicts',
        where: 'entity_type = ? AND entity_key = ? AND field_name = ?',
        whereArgs: [row['entity_type'], row['entity_key'], row['field_name']],
      );
      final data = {
        'entity_type': row['entity_type'],
        'entity_key': row['entity_key'],
        'field_name': row['field_name'],
        'value_a': row['value_a'],
        'source_a': row['source_a'],
        'value_b': row['value_b'],
        'source_b': row['source_b'],
        'status': row['status'],
        'notes': row['notes'],
      };
      if (existing.isEmpty) {
        await store.insert('data_conflicts', data);
        continue;
      }
      if (existing.first['status'] == 'reviewed' &&
          existing.first['value_a'] == row['value_a'] &&
          existing.first['value_b'] == row['value_b']) {
        data['status'] = 'reviewed';
      }
      await store.update(
        'data_conflicts',
        data,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<void> _markInterchanges(MetroStore store) async {
    final linked = <int, Set<int>>{};
    for (final row in store.all('line_stations')) {
      linked.putIfAbsent(row['station_id'] as int, () => {}).add(row['line_id'] as int);
    }
    final interchangeIds = <int>{
      for (final entry in linked.entries)
        if (entry.value.length > 1) entry.key,
      for (final row in store.all('interchanges')) ...[
        row['from_station_id'] as int,
        row['to_station_id'] as int,
      ],
    };
    for (final station in store.all('stations')) {
      if ((station['manually_corrected'] as int? ?? 0) == 1) {
        continue;
      }
      await store.update(
        'stations',
        {'is_interchange': interchangeIds.contains(station['id']) ? 1 : 0},
        where: 'id = ?',
        whereArgs: [station['id']],
      );
    }
  }

  Future<int> _upsertBy(
    MetroStore store,
    String table,
    String keyColumn,
    String key,
    Map<String, Object?> data,
  ) async {
    final existing = await store.query(
      table,
      where: '$keyColumn = ?',
      whereArgs: [key],
    );
    if (existing.isEmpty) {
      return store.insert(table, data);
    }
    final id = existing.first['id'] as int;
    await store.update(table, data, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  Future<void> _meta(MetroStore store, String key, String value) async {
    await store.insert('meta', {
      'key': key,
      'value': value,
    }, conflict: StoreConflict.replace);
  }

  int _rank(String status) {
    const ranks = {
      'manual_review': 100,
      'official': 80,
      'official_inferred': 70,
      'mixed': 65,
      'operator_published': 60,
      'operator_map_embed': 55,
      'secondary': 40,
      'historical_official': 30,
      'unconfirmed': 20,
      'unavailable': 10,
    };
    return ranks[status] ?? 0;
  }
}

class _StationWrite {
  const _StationWrite(this.id, this.skipped);

  final int id;
  final bool skipped;
}
