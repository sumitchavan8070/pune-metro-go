import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/service_alert_model.dart';

class AlertRepository {
  AlertRepository(this._store);

  final MetroStore _store;

  Future<List<ServiceAlertModel>> all() async {
    final rows = _store.all('service_alerts').map((row) {
      String? lineName;
      String? stationName;
      String? sourceName;
      String? sourceUrl;
      for (final line in _store.all('metro_lines')) {
        if (line['id'] == row['line_id']) {
          lineName = line['name'] as String;
        }
      }
      for (final station in _store.all('stations')) {
        if (station['id'] == row['station_id']) {
          stationName = station['name'] as String;
        }
      }
      for (final source in _store.all('data_sources')) {
        if (source['id'] == row['source_id']) {
          sourceName = source['source_name'] as String?;
          sourceUrl = source['source_url'] as String?;
        }
      }
      return {
        ...row,
        'line_name': lineName,
        'station_name': stationName,
        'source_name': sourceName,
        'source_url': sourceUrl,
      };
    }).toList()
      ..sort((a, b) => (b['start_time'] as String? ?? '').compareTo(a['start_time'] as String? ?? ''));
    return rows.map(ServiceAlertModel.fromMap).toList();
  }

  Future<List<ServiceAlertModel>> active({DateTime? at}) async {
    final moment = at ?? DateTime.now();
    final rows = await all();
    return rows.where((alert) => alert.isActiveAt(moment)).toList();
  }
}
