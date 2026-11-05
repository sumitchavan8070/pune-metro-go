import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/data/dataset/dataset_validator.dart';
import 'package:pune_metro_guide/data/services/dio_service.dart';

class SourceCheckResult {
  const SourceCheckResult({
    required this.sourceKey,
    required this.url,
    required this.reachable,
    required this.missingTerms,
    this.statusCode,
    this.message,
  });

  final String sourceKey;
  final String url;
  final bool reachable;
  final int? statusCode;
  final List<String> missingTerms;
  final String? message;

  bool get matches => reachable && missingTerms.isEmpty;
}

class WebExtractionService {
  WebExtractionService(this._dio, this._logger) : _validator = const DatasetValidator();

  final DioService _dio;
  final AppLogger _logger;
  final DatasetValidator _validator;

  /// Checks public pages for expected phrases. It never writes station rows.
  Future<List<SourceCheckResult>> checkPublishedPages(
    List<Map<String, dynamic>> checks,
  ) async {
    final results = <SourceCheckResult>[];
    for (final check in checks) {
      final url = check['url'] as String;
      final key = check['source_key'] as String;
      final terms = (check['must_contain'] as List).cast<String>();
      try {
        final response = await _dio.client.get<String>(url);
        final body = response.data ?? '';
        final missing = _validator.missingTerms(body, terms);
        results.add(
          SourceCheckResult(
            sourceKey: key,
            url: url,
            reachable: response.statusCode == 200,
            statusCode: response.statusCode,
            missingTerms: missing,
            message: response.statusCode == 200
                ? null
                : 'Page returned HTTP ${response.statusCode}. The stored dataset was not changed.',
          ),
        );
      } catch (error) {
        _logger.error('Source check failed for $url', error: error);
        results.add(
          SourceCheckResult(
            sourceKey: key,
            url: url,
            reachable: false,
            missingTerms: terms,
            message: 'Could not read this page. The stored dataset was not changed.',
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
    return results;
  }
}
