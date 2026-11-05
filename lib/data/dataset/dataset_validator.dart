class DatasetValidation {
  const DatasetValidation(this.errors);

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}

class DatasetValidator {
  const DatasetValidator();

  static const statuses = {
    'operational',
    'partially_operational',
    'not_open',
    'reported_open',
    'reported_closed',
    'under_construction',
    'planned',
    'suspended',
  };

  static const verifications = {
    'official',
    'official_inferred',
    'operator_published',
    'operator_map_embed',
    'secondary',
    'historical_official',
    'unconfirmed',
    'manual_review',
    'mixed',
    'unavailable',
  };

  DatasetValidation validate(Map<String, dynamic> json) {
    final errors = <String>[];
    final version = json['dataset_version'];
    if (version is! String || version.isEmpty) {
      errors.add('dataset_version is required.');
    }
    if (json['extracted_at'] is! String) {
      errors.add('extracted_at is required.');
    }

    final stations = _maps(json['stations'], errors, 'stations');
    final lines = _maps(json['lines'], errors, 'lines');
    final links = _maps(json['line_stations'], errors, 'line_stations');
    final sources = _maps(json['sources'], errors, 'sources');
    final operators = _maps(json['operators'], errors, 'operators');
    final timetables = _maps(json['timetables'], errors, 'timetables');
    final fares = _maps(json['fares'], errors, 'fares');
    final stationTimes = _maps(json['station_timetables'], errors, 'station_timetables');
    final interchanges = _maps(json['interchanges'], errors, 'interchanges');
    final conflicts = _maps(json['conflicts'], errors, 'conflicts');

    final stationCodes = _unique(stations, 'code', errors, 'station');
    final lineCodes = _unique(lines, 'code', errors, 'line');
    final sourceKeys = _unique(sources, 'key', errors, 'source');
    _unique(operators, 'key', errors, 'operator');

    for (final source in sources) {
      _checkVerification(source['verification_status'], errors, 'source ${source['key']}');
    }

    for (final line in lines) {
      final code = line['code'];
      if (line['operator_key'] is! String) {
        errors.add('Line $code is missing an operator.');
      }
      if (!_isHex(line['color'])) {
        errors.add('Line $code has no #RRGGBB colour.');
      }
      _checkStatus(line['operational_status'], errors, 'line $code');
      _checkVerification(line['verification_status'], errors, 'line $code');
      final origin = line['origin_station_code'];
      final destination = line['destination_station_code'];
      if (origin != null && !stationCodes.contains(origin)) {
        errors.add('Line $code origin $origin is missing.');
      }
      if (destination != null && !stationCodes.contains(destination)) {
        errors.add('Line $code destination $destination is missing.');
      }
      final source = line['source_key'];
      if (source is! String || !sourceKeys.contains(source)) {
        errors.add('Line $code source is missing.');
      }
    }

    for (final station in stations) {
      final code = station['code'];
      _checkStatus(station['operational_status'], errors, 'station $code');
      _checkVerification(station['verification_status'], errors, 'station $code');
      _checkVerification(station['status_verification'], errors, 'station $code status');
      final lat = station['latitude'];
      final lon = station['longitude'];
      final hasLat = lat != null;
      final hasLon = lon != null;
      if (hasLat != hasLon) {
        errors.add('Station $code has only one coordinate.');
      }
      if (hasLat) {
        _checkVerification(
          station['coordinate_verification'],
          errors,
          'station $code coordinate',
        );
        final source = station['coordinate_source_key'];
        if (source is! String || !sourceKeys.contains(source)) {
          errors.add('Station $code coordinate has no source.');
        }
      }
      final source = station['source_key'];
      if (source is! String || !sourceKeys.contains(source)) {
        errors.add('Station $code source is missing.');
      }
    }

    final grouped = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final link in links) {
      final line = link['line_code'];
      final station = link['station_code'];
      final direction = link['direction'];
      final sequence = link['sequence_number'];
      if (!lineCodes.contains(line)) {
        errors.add('Line station references unknown line $line.');
        continue;
      }
      if (!stationCodes.contains(station)) {
        errors.add('Line station references unknown station $station.');
        continue;
      }
      if (direction is! String || sequence is! int) {
        errors.add('Line station $line/$station is missing direction or sequence.');
        continue;
      }
      grouped.putIfAbsent(line as String, () => {});
      grouped[line]!.putIfAbsent(direction, () => []);
      grouped[line]![direction]!.add(link);
    }

    for (final line in lines) {
      final code = line['code'] as String?;
      if (code == null) {
        continue;
      }
      final directions = grouped[code];
      final origin = line['origin_station_code'];
      if (origin == null) {
        if (directions != null && directions.isNotEmpty) {
          errors.add('Line $code has stations but no origin.');
        }
        continue;
      }
      if (directions == null || directions.length != 2) {
        errors.add('Line $code must have two directions.');
        continue;
      }
      final lists = directions.values.toList();
      for (final rows in lists) {
        rows.sort(
          (a, b) => (a['sequence_number'] as int).compareTo(b['sequence_number'] as int),
        );
        final numbers = rows.map((row) => row['sequence_number'] as int).toList();
        final expected = List<int>.generate(rows.length, (index) => index + 1);
        if (numbers.join(',') != expected.join(',')) {
          errors.add('Line $code sequence is not contiguous.');
        }
        final seen = <Object?>{};
        for (final row in rows) {
          if (!seen.add(row['station_code'])) {
            errors.add('Line $code repeats ${row['station_code']}.');
          }
        }
      }
      final forward = lists[0].map((row) => row['station_code']).toList();
      final reverse = lists[1].map((row) => row['station_code']).toList().reversed.toList();
      if (forward.join('|') != reverse.join('|')) {
        errors.add('Line $code directions are not reverses of each other.');
      }
      if (forward.first != origin || forward.last != line['destination_station_code']) {
        final otherFirst = lists[1].first['station_code'];
        final otherLast = lists[1].last['station_code'];
        final matchesForward = forward.first == origin && forward.last == line['destination_station_code'];
        final matchesOther = otherFirst == origin && otherLast == line['destination_station_code'];
        if (!matchesForward && !matchesOther) {
          errors.add('Line $code origin or destination does not match the sequence.');
        }
      }
    }

    final regulars = <String, int>{};
    for (final row in timetables) {
      final line = row['line_code'];
      if (!lineCodes.contains(line)) {
        errors.add('Timetable references unknown line $line.');
      }
      _checkVerification(row['verification_status'], errors, 'timetable $line');
      if (row['service_type'] == 'regular' && row['valid_until'] == null) {
        regulars[line as String] = (regulars[line] ?? 0) + 1;
      }
      if (row['peak_headway_minutes'] != null && stationTimes.isNotEmpty) {
        errors.add('Headway must not be expanded into station departures.');
      }
    }
    for (final entry in regulars.entries) {
      if (entry.value > 1) {
        errors.add('Line ${entry.key} has more than one current regular timetable.');
      }
    }
    if (stationTimes.isNotEmpty) {
      errors.add('Station departure rows are not accepted from this dataset.');
    }

    for (final fare in fares) {
      if (fare['amount'] is! num || fare['currency'] is! String) {
        errors.add('Fare is missing an amount or currency.');
      }
      _checkVerification(fare['verification_status'], errors, 'fare');
      if (!stationCodes.contains(fare['origin_station_code']) ||
          !stationCodes.contains(fare['destination_station_code'])) {
        errors.add('Fare references a missing station.');
      }
    }

    for (final interchange in interchanges) {
      if (!stationCodes.contains(interchange['from_station_code']) ||
          !stationCodes.contains(interchange['to_station_code'])) {
        errors.add('Interchange references a missing station.');
      }
      if (interchange['use_for_routing'] is! bool) {
        errors.add('Interchange is missing use_for_routing.');
      }
      final walking = interchange['walking_minutes'];
      if (walking != null && (walking is! int || walking < 0)) {
        errors.add('Interchange walking time is invalid.');
      }
    }

    for (final conflict in conflicts) {
      for (final field in ['entity_type', 'entity_key', 'field_name', 'status', 'value_a', 'value_b']) {
        if (conflict[field] == null) {
          errors.add('Conflict is missing $field.');
        }
      }
    }

    return DatasetValidation(errors);
  }

  List<String> missingTerms(String body, List<String> terms) {
    return terms.where((term) => !body.contains(term)).toList();
  }

  List<Map<String, dynamic>> _maps(Object? value, List<String> errors, String label) {
    if (value is! List) {
      errors.add('$label must be a list.');
      return [];
    }
    final rows = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        rows.add(item);
      } else if (item is Map) {
        rows.add(item.map((key, mapValue) => MapEntry(key.toString(), mapValue)));
      } else {
        errors.add('$label contains a row that is not an object.');
      }
    }
    return rows;
  }

  Set<String> _unique(
    List<Map<String, dynamic>> rows,
    String field,
    List<String> errors,
    String label,
  ) {
    final seen = <String>{};
    for (final row in rows) {
      final value = row[field];
      if (value is! String || value.isEmpty) {
        errors.add('A $label is missing $field.');
        continue;
      }
      if (!seen.add(value)) {
        errors.add('Duplicate $label $field: $value.');
      }
    }
    return seen;
  }

  void _checkStatus(Object? value, List<String> errors, String label) {
    if (value is! String || !statuses.contains(value)) {
      errors.add('$label has an unknown operational status.');
    }
  }

  void _checkVerification(Object? value, List<String> errors, String label) {
    if (value is! String || !verifications.contains(value)) {
      errors.add('$label has an unknown verification status.');
    }
  }

  bool _isHex(Object? value) {
    return value is String && RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value);
  }
}
