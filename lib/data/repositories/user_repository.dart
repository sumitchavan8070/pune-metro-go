import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/models/trip_model.dart';

class UserRepository {
  UserRepository(this._store);

  final MetroStore _store;

  Future<List<FavouriteModel>> favourites() async {
    final rows = _store.all('favourites').map(_labelled).toList()
      ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return rows.map(FavouriteModel.fromMap).toList();
  }

  Future<bool> isFavouriteStation(int stationId) async {
    return _store.all('favourites').any((row) => row['item_type'] == 'station' && row['item_id'] == stationId);
  }

  Future<void> setStationFavourite(int stationId, bool favourite) async {
    if (!favourite) {
      await _store.delete(
        'favourites',
        where: 'item_type = ? AND item_id = ?',
        whereArgs: ['station', stationId],
      );
      return;
    }
    await _store.insert(
      'favourites',
      {
        'item_type': 'station',
        'item_id': stationId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflict: StoreConflict.ignore,
    );
  }

  Future<void> saveJourneyFavourite(int originId, int destinationId) async {
    final itemId = originId * 100000 + destinationId;
    await _store.insert(
      'favourites',
      {
        'item_type': 'journey',
        'item_id': itemId,
        'origin_station_id': originId,
        'destination_station_id': destinationId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflict: StoreConflict.replace,
    );
  }

  Future<void> deleteFavourite(int id) async {
    await _store.delete('favourites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecentJourneyModel>> recentJourneys() async {
    final rows = _store.all('recent_journeys').map((row) {
      return {
        ...row,
        'origin_name': _stationName(row['origin_station_id'] as int),
        'destination_name': _stationName(row['destination_station_id'] as int),
      };
    }).toList()
      ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    final limited = rows.length > 12 ? rows.sublist(0, 12) : rows;
    return limited.map(RecentJourneyModel.fromMap).toList();
  }

  Future<void> rememberJourney(int originId, int destinationId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _store.insert('recent_journeys', {
      'origin_station_id': originId,
      'destination_station_id': destinationId,
      'journey_date': now.substring(0, 10),
      'created_at': now,
    });
    final rows = _store.all('recent_journeys')..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    if (rows.length > 20) {
      for (final row in rows.skip(20)) {
        await _store.delete('recent_journeys', where: 'id = ?', whereArgs: [row['id']]);
      }
    }
  }

  Future<void> deleteRecent(int id) async {
    await _store.delete('recent_journeys', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearRecent() async {
    await _store.delete('recent_journeys');
  }

  Map<String, dynamic> _labelled(Map<String, dynamic> row) {
    if (row['item_type'] == 'station') {
      final station = _station(row['item_id'] as int);
      return {
        ...row,
        'label': station?['name'],
        'detail': station?['operational_status'],
      };
    }
    final origin = _stationName(row['origin_station_id'] as int?);
    final destination = _stationName(row['destination_station_id'] as int?);
    return {...row, 'label': '$origin to $destination'};
  }

  Map<String, dynamic>? _station(int? id) {
    if (id == null) {
      return null;
    }
    for (final row in _store.all('stations')) {
      if (row['id'] == id) {
        return row;
      }
    }
    return null;
  }

  String? _stationName(int? id) => _station(id)?['name'] as String?;
}
