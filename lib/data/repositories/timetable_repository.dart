import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/timetable_model.dart';

class TimetableRepository {
  TimetableRepository(this._store);

  final MetroStore _store;

  Future<List<TimetableModel>> forLine(int lineId) async {
    final rows = _store.all('timetables').where((row) => row['line_id'] == lineId).map(_withNames).toList()
      ..sort((a, b) => (b['valid_from'] as String? ?? '').compareTo(a['valid_from'] as String? ?? ''));
    return rows.map(TimetableModel.fromMap).toList();
  }

  Future<List<TimetableModel>> all() async {
    final rows = _store.all('timetables').map(_withNames).toList()
      ..sort((a, b) {
        final name = (a['line_name'] as String? ?? '').compareTo(b['line_name'] as String? ?? '');
        if (name != 0) {
          return name;
        }
        return (b['valid_from'] as String? ?? '').compareTo(a['valid_from'] as String? ?? '');
      });
    return rows.map(TimetableModel.fromMap).toList();
  }

  Future<List<StationTimetableModel>> departures(int timetableId) async {
    final stations = {for (final row in _store.all('stations')) row['id'] as int: row['name'] as String};
    final rows = _store.all('station_timetables').where((row) => row['timetable_id'] == timetableId).map((row) {
      return {...row, 'station_name': stations[row['station_id']]};
    }).toList()
      ..sort((a, b) => (a['departure_time'] as String).compareTo(b['departure_time'] as String));
    return rows.map(StationTimetableModel.fromMap).toList();
  }

  Map<String, dynamic> _withNames(Map<String, dynamic> row) {
    String? lineName;
    for (final line in _store.all('metro_lines')) {
      if (line['id'] == row['line_id']) {
        lineName = line['name'] as String;
      }
    }
    String? sourceName;
    String? sourceUrl;
    for (final source in _store.all('data_sources')) {
      if (source['id'] == row['source_id']) {
        sourceName = source['source_name'] as String?;
        sourceUrl = source['source_url'] as String?;
      }
    }
    return {...row, 'line_name': lineName, 'source_name': sourceName, 'source_url': sourceUrl};
  }
}
