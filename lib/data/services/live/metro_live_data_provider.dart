import 'package:pune_metro_guide/data/services/live/live_models.dart';

/// Future seam for an authorised GTFS-Realtime or operator feed.
/// The app does not ship an implementation that invents train positions.
abstract class MetroLiveDataProvider {
  Future<List<LiveTrainPosition>> getTrainPositions();

  Future<List<TripUpdate>> getTripUpdates();

  Future<List<LiveServiceAlert>> getLiveServiceAlerts();
}

class NoLiveFeedConnected implements MetroLiveDataProvider {
  const NoLiveFeedConnected();

  @override
  Future<List<LiveTrainPosition>> getTrainPositions() {
    throw const LiveFeedNotConnectedException();
  }

  @override
  Future<List<TripUpdate>> getTripUpdates() {
    throw const LiveFeedNotConnectedException();
  }

  @override
  Future<List<LiveServiceAlert>> getLiveServiceAlerts() {
    throw const LiveFeedNotConnectedException();
  }
}
