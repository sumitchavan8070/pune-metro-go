import 'package:geolocator/geolocator.dart';

class LocationFix {
  const LocationFix({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationOutcome {
  const LocationOutcome._({this.fix, this.message});

  final LocationFix? fix;
  final String? message;

  bool get granted => fix != null;

  factory LocationOutcome.ready(double latitude, double longitude) {
    return LocationOutcome._(fix: LocationFix(latitude: latitude, longitude: longitude));
  }

  factory LocationOutcome.blocked(String message) {
    return LocationOutcome._(message: message);
  }
}

class LocationService {
  Future<LocationFix?> lastKnown() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return null;
      }
      return LocationFix(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<LocationOutcome> currentFix() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return LocationOutcome.blocked(
        'Location services are turned off. Search for a station by name instead.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return LocationOutcome.blocked(
        'Location permission was denied. Nearby stations stay hidden, and search still works.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationOutcome.blocked(
        'Location permission is blocked for this app. You can enable it in system settings, or search by name.',
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationOutcome.ready(position.latitude, position.longitude);
    } catch (_) {
      return LocationOutcome.blocked(
        'Your location could not be read. Search for a station by name instead.',
      );
    }
  }
}
