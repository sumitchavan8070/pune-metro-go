import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/interchange_model.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/station_facility_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';

class MetroRepository {
  MetroRepository(this._store);

  final MetroStore _store;

  Future<List<MetroLineModel>> lines() async {
    final rows = [
      for (final line in _store.all('metro_lines')) _lineRow(line),
    ]..sort((a, b) {
        final status = _statusRank(a['operational_status'] as String).compareTo(
          _statusRank(b['operational_status'] as String),
        );
        if (status != 0) {
          return status;
        }
        return (a['name'] as String).compareTo(b['name'] as String);
      });
    return rows.map(MetroLineModel.fromMap).toList();
  }

  Future<MetroLineModel?> line(int id) async {
    for (final item in await lines()) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<List<StationModel>> stationsOnLine(int lineId) async {
    final line = _byId('metro_lines', lineId);
    if (line == null) {
      return [];
    }
    final links = _store.all('line_stations').where((row) => row['line_id'] == lineId).toList();
    final originLink = links.where(
      (row) => row['sequence_number'] == 1 && row['station_id'] == line['origin_station_id'],
    );
    if (originLink.isEmpty) {
      return [];
    }
    final direction = originLink.first['direction'];
    final ordered = links.where((row) => row['direction'] == direction).toList()
      ..sort((a, b) => (a['sequence_number'] as int).compareTo(b['sequence_number'] as int));
    return _decorate([
      for (final link in ordered)
        if (_byId('stations', link['station_id'] as int) != null)
          StationModel.fromMap(_byId('stations', link['station_id'] as int)!),
    ]);
  }

  Future<List<StationModel>> search(String query) async {
    final raw = query.trim().toLowerCase();
    final term = normalizeStationName(query);
    if (raw.isEmpty) {
      return [];
    }
    final aliasIds = {
      for (final alias in _store.all('station_aliases'))
        if (_nameHits(alias['normalized_alias'] as String, term)) alias['station_id'] as int,
    };
    final matches = _store.all('stations').where((station) {
      final name = _nameHits(station['normalized_name'] as String, term);
      final code = (station['station_code'] as String).toLowerCase().contains(raw);
      return name || code || aliasIds.contains(station['id']);
    }).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    final limited = matches.length > 40 ? matches.sublist(0, 40) : matches;
    return _decorate(limited.map(StationModel.fromMap).toList());
  }

  Future<List<StationModel>> allStations() async {
    final rows = _store.all('stations')..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return _decorate(rows.map(StationModel.fromMap).toList());
  }

  Future<StationModel?> station(int id) async {
    final row = _byId('stations', id);
    if (row == null) {
      return null;
    }
    final source = row['source_id'] == null ? null : _byId('data_sources', row['source_id'] as int);
    final withSource = {
      ...row,
      'source_name': source?['source_name'],
      'source_url': source?['source_url'],
    };
    final withLines = await _decorate([StationModel.fromMap(withSource)]);
    return withLines.first;
  }

  Future<List<StationAliasModel>> aliases(int stationId) async {
    final rows = _store.all('station_aliases').where((row) => row['station_id'] == stationId).map((row) {
      final source = row['source_id'] == null ? null : _byId('data_sources', row['source_id'] as int);
      return {
        ...row,
        'source_name': source?['source_name'],
      };
    }).toList()
      ..sort((a, b) => (a['alias'] as String).compareTo(b['alias'] as String));
    return rows.map(StationAliasModel.fromMap).toList();
  }

  Future<List<InterchangeModel>> interchangesFor(int stationId) async {
    final rows = _store.all('interchanges').where(
      (row) => row['from_station_id'] == stationId || row['to_station_id'] == stationId,
    );
    return rows.map(_interchange).toList();
  }

  Future<List<StationFacilityModel>> facilities(int stationId) async {
    final rows = _store.all('station_facilities').where((row) => row['station_id'] == stationId).map((row) {
      final source = row['source_id'] == null ? null : _byId('data_sources', row['source_id'] as int);
      return {...row, 'source_name': source?['source_name']};
    });
    return rows.map(StationFacilityModel.fromMap).toList();
  }

  Future<List<MetroLineModel>> linesForStation(int stationId) async {
    final lineIds = {
      for (final link in _store.all('line_stations'))
        if (link['station_id'] == stationId) link['line_id'] as int,
    };
    final rows = [
      for (final line in _store.all('metro_lines'))
        if (lineIds.contains(line['id'])) _lineRow(line),
    ]..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return rows.map(MetroLineModel.fromMap).toList();
  }

  Future<List<LineStationModel>> lineStations() async {
    return _store.all('line_stations').map(LineStationModel.fromMap).toList();
  }

  Future<List<InterchangeModel>> allInterchanges() async {
    return _store.all('interchanges').map(_interchange).toList();
  }

  Future<Map<String, String>> meta() async {
    return {
      for (final row in _store.all('meta')) row['key'] as String: row['value'] as String,
    };
  }

  Map<String, dynamic> _lineRow(Map<String, dynamic> line) {
    final operator = _byId('metro_operators', line['operator_id'] as int);
    final origin = line['origin_station_id'] == null ? null : _byId('stations', line['origin_station_id'] as int);
    final destination = line['destination_station_id'] == null
        ? null
        : _byId('stations', line['destination_station_id'] as int);
    final source = line['source_id'] == null ? null : _byId('data_sources', line['source_id'] as int);
    return {
      ...line,
      'operator_name': operator?['name'],
      'origin_name': origin?['name'],
      'destination_name': destination?['name'],
      'source_name': source?['source_name'],
    };
  }

  InterchangeModel _interchange(Map<String, dynamic> row) {
    final source = row['source_id'] == null ? null : _byId('data_sources', row['source_id'] as int);
    return InterchangeModel.fromMap({
      ...row,
      'from_name': _byId('stations', row['from_station_id'] as int)?['name'],
      'to_name': _byId('stations', row['to_station_id'] as int)?['name'],
      'source_name': source?['source_name'],
    });
  }

  Map<String, dynamic>? _byId(String table, int id) {
    for (final row in _store.all(table)) {
      if (row['id'] == id) {
        return row;
      }
    }
    return null;
  }

  bool _nameHits(String normalized, String term) {
    if (term.isEmpty) {
      return false;
    }
    if (normalized.contains(term)) {
      return true;
    }
    final compactTerm = term.replaceAll(' ', '');
    if (compactTerm.length < 3) {
      return false;
    }
    return normalized.replaceAll(' ', '').contains(compactTerm);
  }

  Future<List<StationModel>> _decorate(List<StationModel> stations) {
    return _withLines(stations).then((withLines) {
      final aliases = <int, List<String>>{};
      for (final row in _store.all('station_aliases')) {
        final name = row['alias'] as String?;
        if (name == null || name.isEmpty) {
          continue;
        }
        final list = aliases.putIfAbsent(row['station_id'] as int, () => []);
        if (!list.contains(name)) {
          list.add(name);
        }
      }
      return [
        for (final station in withLines) station.copyWith(aliasNames: aliases[station.id] ?? const []),
      ];
    });
  }

  Future<List<StationModel>> _withLines(List<StationModel> stations) async {
    if (stations.isEmpty) {
      return stations;
    }
    final names = <int, List<String>>{};
    final lines = {for (final line in _store.all('metro_lines')) line['id'] as int: line['name'] as String};
    for (final link in _store.all('line_stations')) {
      final name = lines[link['line_id']];
      if (name == null) {
        continue;
      }
      final list = names.putIfAbsent(link['station_id'] as int, () => []);
      if (!list.contains(name)) {
        list.add(name);
      }
    }
    return [
      for (final station in stations) station.copyWith(lineNames: names[station.id] ?? const []),
    ];
  }

  int _statusRank(String status) {
    switch (status) {
      case 'operational':
        return 0;
      case 'partially_operational':
        return 1;
      case 'under_construction':
        return 2;
      default:
        return 3;
    }
  }
}
