import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/fare_model.dart';

class FareRepository {
  FareRepository(this._store);

  final MetroStore _store;

  Future<List<FareModel>> all() async {
    final rows = _store.all('fares').map((row) {
      String? sourceName;
      String? sourceUrl;
      for (final source in _store.all('data_sources')) {
        if (source['id'] == row['source_id']) {
          sourceName = source['source_name'] as String?;
          sourceUrl = source['source_url'] as String?;
        }
      }
      return {...row, 'source_name': sourceName, 'source_url': sourceUrl};
    });
    return rows.map(FareModel.fromMap).toList();
  }

  Future<int> count() async => _store.all('fares').length;
}
