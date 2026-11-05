class FareModel {
  const FareModel({
    required this.id,
    required this.originStationId,
    required this.destinationStationId,
    required this.amount,
    required this.currency,
    required this.verificationStatus,
    this.lineId,
    this.validFrom,
    this.validUntil,
    this.sourceId,
    this.sourceName,
    this.sourceUrl,
  });

  final int id;
  final int? lineId;
  final int originStationId;
  final int destinationStationId;
  final double amount;
  final String currency;
  final String? validFrom;
  final String? validUntil;
  final int? sourceId;
  final String verificationStatus;
  final String? sourceName;
  final String? sourceUrl;

  bool get isTrusted =>
      verificationStatus == 'official' || verificationStatus == 'operator_published';

  factory FareModel.fromMap(Map<String, Object?> row) {
    return FareModel(
      id: row['id'] as int,
      lineId: row['line_id'] as int?,
      originStationId: row['origin_station_id'] as int,
      destinationStationId: row['destination_station_id'] as int,
      amount: (row['amount'] as num).toDouble(),
      currency: row['currency'] as String,
      validFrom: row['valid_from'] as String?,
      validUntil: row['valid_until'] as String?,
      sourceId: row['source_id'] as int?,
      verificationStatus: row['verification_status'] as String,
      sourceName: row['source_name'] as String?,
      sourceUrl: row['source_url'] as String?,
    );
  }
}

class FareQuote {
  const FareQuote._({
    required this.available,
    required this.message,
    this.amount,
    this.currency,
    this.sourceName,
    this.sourceUrl,
    this.validFrom,
  });

  final bool available;
  final String message;
  final double? amount;
  final String? currency;
  final String? sourceName;
  final String? sourceUrl;
  final String? validFrom;

  factory FareQuote.unavailable(String message) {
    return FareQuote._(available: false, message: message);
  }

  factory FareQuote.available(FareModel fare) {
    return FareQuote._(
      available: true,
      message: 'Verified fare',
      amount: fare.amount,
      currency: fare.currency,
      sourceName: fare.sourceName,
      sourceUrl: fare.sourceUrl,
      validFrom: fare.validFrom,
    );
  }
}
