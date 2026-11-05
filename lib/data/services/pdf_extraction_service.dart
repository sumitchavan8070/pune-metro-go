import 'package:pune_metro_guide/data/services/dio_service.dart';

class RejectedDocument {
  const RejectedDocument({
    required this.title,
    required this.url,
    required this.reason,
    this.reachable,
  });

  final String title;
  final String url;
  final String reason;
  final bool? reachable;
}

class PdfExtractionService {
  PdfExtractionService(this._dio);

  final DioService _dio;

  List<RejectedDocument> describe(List<Map<String, dynamic>> rows) {
    return [
      for (final row in rows)
        RejectedDocument(
          title: row['title'] as String,
          url: row['url'] as String,
          reason: row['reason'] as String,
        ),
    ];
  }

  /// Confirms a public document is still reachable. It does not parse or import it.
  Future<List<RejectedDocument>> checkHeaders(List<RejectedDocument> documents) async {
    final checked = <RejectedDocument>[];
    for (final document in documents) {
      var reachable = false;
      try {
        final response = await _dio.client.head<void>(document.url);
        reachable = response.statusCode == 200 || response.statusCode == 302;
      } catch (_) {
        reachable = false;
      }
      checked.add(
        RejectedDocument(
          title: document.title,
          url: document.url,
          reason: document.reason,
          reachable: reachable,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return checked;
  }
}
