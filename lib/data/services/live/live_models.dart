class LiveTrainPosition {
  const LiveTrainPosition({
    required this.trainId,
    required this.lineCode,
    required this.latitude,
    required this.longitude,
    required this.observedAt,
  });

  final String trainId;
  final String lineCode;
  final double latitude;
  final double longitude;
  final DateTime observedAt;
}

class TripUpdate {
  const TripUpdate({
    required this.tripId,
    required this.lineCode,
    required this.stopId,
    this.arrival,
    this.departure,
  });

  final String tripId;
  final String lineCode;
  final String stopId;
  final DateTime? arrival;
  final DateTime? departure;
}

class LiveServiceAlert {
  const LiveServiceAlert({
    required this.id,
    required this.title,
    required this.description,
    this.lineCode,
  });

  final String id;
  final String title;
  final String description;
  final String? lineCode;
}

class LiveFeedNotConnectedException implements Exception {
  const LiveFeedNotConnectedException();

  @override
  String toString() =>
      'No authorised live metro feed is connected. Scheduled information is being shown instead.';
}
