import 'dart:convert';
import 'dart:io';

import 'package:pune_metro_guide/data/dataset/dataset_validator.dart';

/// Validates the reviewed dataset and optionally checks that public pages
/// still contain the phrases recorded on 4 Nov 2026.
///
///   dart run tool/import_metro_data.dart
///   dart run tool/import_metro_data.dart --check-urls
Future<void> main(List<String> args) async {
  final file = File('assets/data/pune_metro_dataset.json');
  if (!file.existsSync()) {
    stderr.writeln('Missing ${file.path}. Run python3 tool/build_dataset.py first.');
    exitCode = 1;
    return;
  }
  final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final validation = const DatasetValidator().validate(json);
  final report = <String, Object?>{
    'dataset_version': json['dataset_version'],
    'extracted_at': json['extracted_at'],
    'valid': validation.isValid,
    'errors': validation.errors,
    'operators': (json['operators'] as List).length,
    'lines': (json['lines'] as List).length,
    'stations': (json['stations'] as List).length,
    'operational_or_reported_open': (json['stations'] as List)
        .where((row) => row['operational_status'] == 'operational' || row['operational_status'] == 'reported_open')
        .length,
    'not_in_passenger_service': (json['stations'] as List)
        .where((row) => row['operational_status'] != 'operational' && row['operational_status'] != 'reported_open')
        .length,
    'timetables': (json['timetables'] as List).length,
    'fares': (json['fares'] as List).length,
    'station_departures': (json['station_timetables'] as List).length,
    'conflicts': (json['conflicts'] as List).length,
    'missing_coordinates': (json['stations'] as List)
        .where((row) => row['latitude'] == null)
        .map((row) => row['code'])
        .toList(),
  };

  if (args.contains('--check-urls')) {
    report['url_checks'] = await _checkUrls(json);
  }

  final output = File('tool/reports/import_report.json');
  await output.parent.create(recursive: true);
  await output.writeAsString(const JsonEncoder.withIndent('  ').convert(report));
  stdout.writeln('Wrote ${output.path}');
  if (!validation.isValid) {
    for (final error in validation.errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
  }
}

Future<List<Map<String, Object?>>> _checkUrls(Map<String, dynamic> json) async {
  final validator = const DatasetValidator();
  final checks = (json['source_checks'] as List).cast<Map>().map(Map<String, dynamic>.from);
  final client = HttpClient();
  final results = <Map<String, Object?>>[];
  try {
    for (final check in checks) {
      final url = check['url'] as String;
      final terms = (check['must_contain'] as List).cast<String>();
      try {
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set(HttpHeaders.userAgentHeader, 'PuneMetroGuide/1.0 (dataset check)');
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        final missing = validator.missingTerms(body, terms);
        results.add({
          'source_key': check['source_key'],
          'status': response.statusCode,
          'missing': missing,
        });
      } catch (error) {
        results.add({
          'source_key': check['source_key'],
          'error': error.toString(),
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
  } finally {
    client.close();
  }
  return results;
}
