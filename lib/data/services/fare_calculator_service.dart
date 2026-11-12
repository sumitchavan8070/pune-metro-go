import 'package:pune_metro_guide/models/fare_model.dart';

class FareCalculatorService {
  const FareCalculatorService();

  static const unavailableMessage =
      'No fare from the imported chart matches this pair. The chart covers the Purple and Aqua stations printed on it. Range Hill, the extensions, and Line 3 are not on that chart.';

  FareQuote quote({
    required int originId,
    required int destinationId,
    required List<FareModel> fares,
    DateTime? onDate,
  }) {
    if (originId == destinationId) {
      return FareQuote.unavailable('Choose two different stations.');
    }
    final day = onDate ?? DateTime.now();
    final matches = fares.where((fare) {
      final samePair = (fare.originStationId == originId &&
              fare.destinationStationId == destinationId) ||
          (fare.originStationId == destinationId &&
              fare.destinationStationId == originId);
      if (!samePair || !fare.isTrusted) {
        return false;
      }
      final from = fare.validFrom == null ? null : DateTime.tryParse(fare.validFrom!);
      final until = fare.validUntil == null ? null : DateTime.tryParse(fare.validUntil!);
      if (from != null && day.isBefore(from)) {
        return false;
      }
      if (until != null && day.isAfter(until)) {
        return false;
      }
      return true;
    }).toList();

    if (matches.isEmpty) {
      return FareQuote.unavailable(unavailableMessage);
    }
    if (matches.length > 1) {
      final amounts = matches.map((fare) => fare.amount).toSet();
      if (amounts.length > 1) {
        return FareQuote.unavailable(
          'This fare is unavailable right now.',
        );
      }
    }
    return FareQuote.available(matches.first);
  }
}
