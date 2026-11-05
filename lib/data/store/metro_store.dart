enum StoreConflict { abort, ignore, replace }

/// In-memory tables for the metro dataset. Firestore is the persistent copy.
class MetroStore {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  final Set<String> _dirty = {};
  bool _batching = false;

  static const tables = [
    'meta',
    'metro_operators',
    'data_sources',
    'stations',
    'metro_lines',
    'line_stations',
    'station_aliases',
    'station_facilities',
    'timetables',
    'station_timetables',
    'fares',
    'interchanges',
    'service_alerts',
    'favourites',
    'recent_journeys',
    'data_conflicts',
    'import_logs',
  ];

  Future<void> hydrate() async {}

  Future<void> flushDirty() async {}

  Future<T> runBatch<T>(Future<T> Function() action) async {
    _batching = true;
    try {
      final result = await action();
      _batching = false;
      await flushDirty();
      return result;
    } catch (_) {
      _batching = false;
      _dirty.clear();
      await hydrate();
      rethrow;
    }
  }

  List<Map<String, dynamic>> all(String table) {
    return _tables[table]?.map(Map<String, dynamic>.from).toList() ?? [];
  }

  void replaceTable(String table, List<Map<String, dynamic>> rows) {
    _tables[table] = rows.map(Map<String, dynamic>.from).toList();
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    List<String>? columns,
    String? orderBy,
    int? limit,
  }) async {
    var rows = all(table).where((row) => _matches(row, where, whereArgs)).toList();
    if (orderBy != null && orderBy.isNotEmpty) {
      final keys = orderBy.split(',');
      rows.sort((a, b) {
        for (final key in keys) {
          final parts = key.trim().split(RegExp(r'\s+'));
          final name = parts.first;
          final descending = parts.length > 1 && parts[1].toUpperCase() == 'DESC';
          final compared = _compare(a[name], b[name]);
          if (compared != 0) {
            return descending ? -compared : compared;
          }
        }
        return 0;
      });
    }
    if (limit != null && rows.length > limit) {
      rows = rows.sublist(0, limit);
    }
    if (columns == null) {
      return rows;
    }
    return [
      for (final row in rows) {for (final column in columns) column: row[column]},
    ];
  }

  Future<int> insert(
    String table,
    Map data, {
    StoreConflict conflict = StoreConflict.abort,
  }) async {
    final incoming = Map<String, dynamic>.from(data);
    final rows = _tables.putIfAbsent(table, () => []);
    final unique = _uniqueColumns[table];
    Map<String, dynamic>? existing;
    if (unique != null) {
      for (final row in rows) {
        if (unique.every((column) => row[column] == incoming[column])) {
          existing = row;
          break;
        }
      }
    }
    if (existing != null) {
      if (conflict == StoreConflict.ignore) {
        return existing['id'] as int? ?? 0;
      }
      if (conflict == StoreConflict.replace || table == 'meta') {
        existing.addAll(incoming);
        await _afterWrite(table);
        return existing['id'] as int? ?? 0;
      }
      throw StateError('Duplicate row in $table');
    }
    final stored = Map<String, dynamic>.from(incoming);
    if (table != 'meta' && stored['id'] == null) {
      stored['id'] = _nextId(table);
    }
    rows.add(stored);
    await _afterWrite(table);
    return stored['id'] as int? ?? 0;
  }

  Future<int> update(
    String table,
    Map data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    var count = 0;
    for (final row in _tables[table] ?? <Map<String, dynamic>>[]) {
      if (_matches(row, where, whereArgs)) {
        row.addAll(Map<String, dynamic>.from(data));
        count++;
      }
    }
    if (count > 0) {
      await _afterWrite(table);
    }
    return count;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = _tables[table];
    if (rows == null) {
      return 0;
    }
    final before = rows.length;
    if (where == null) {
      rows.clear();
    } else {
      rows.removeWhere((row) => _matches(row, where, whereArgs));
    }
    final removed = before - rows.length;
    if (removed > 0) {
      await _afterWrite(table);
    }
    return removed;
  }

  Future<void> _afterWrite(String table) async {
    _dirty.add(table);
    if (!_batching) {
      await flushDirty();
    }
  }

  Set<String> takeDirty() {
    final copy = Set<String>.from(_dirty);
    _dirty.clear();
    return copy;
  }

  int _nextId(String table) {
    var maxId = 0;
    for (final row in _tables[table] ?? const []) {
      final id = row['id'];
      if (id is int && id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
  }

  bool _matches(Map<String, dynamic> row, String? where, List<Object?>? whereArgs) {
    if (where == null) {
      return true;
    }
    final parts = where.split(' AND ');
    var index = 0;
    for (final part in parts) {
      final match = RegExp(r'^(\w+) = \?$').firstMatch(part.trim());
      if (match == null) {
        throw StateError('Unsupported filter: $part');
      }
      if (row[match.group(1)] != whereArgs?[index]) {
        return false;
      }
      index++;
    }
    return true;
  }

  int _compare(Object? a, Object? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return -1;
    }
    if (b == null) {
      return 1;
    }
    if (a is num && b is num) {
      return a.compareTo(b);
    }
    return a.toString().compareTo(b.toString());
  }

  static const _uniqueColumns = {
    'meta': ['key'],
    'metro_operators': ['operator_key'],
    'data_sources': ['source_key'],
    'stations': ['station_code'],
    'metro_lines': ['code'],
    'favourites': ['item_type', 'item_id'],
    'data_conflicts': ['entity_type', 'entity_key', 'field_name'],
    'station_aliases': ['station_id', 'normalized_alias'],
  };
}
