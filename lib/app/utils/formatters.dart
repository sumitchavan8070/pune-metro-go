import 'dart:math' as math;

import 'package:intl/intl.dart';

String normalizeStationName(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String formatClock(String? hhmm) {
  if (hhmm == null || hhmm.isEmpty) {
    return 'Not published';
  }
  final parts = hhmm.split(':');
  if (parts.length < 2) {
    return hhmm;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return hhmm;
  }
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) {
    return 'Not recorded';
  }
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) {
    return iso;
  }
  return DateFormat('d MMM y').format(parsed.toLocal());
}

String formatKilometres(double? km) {
  if (km == null) {
    return 'Not published';
  }
  final rounded = (km * 1000).round() / 1000;
  final text = rounded.toString();
  return '$text km';
}

String formatDistanceMetres(double metres) {
  if (metres < 1000) {
    return '${metres.round()} m';
  }
  return '${(metres / 1000).toStringAsFixed(1)} km';
}

double haversineMetres(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earth = 6371000.0;
  final p1 = _rad(lat1);
  final p2 = _rad(lat2);
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(p1) * math.cos(p2) * math.pow(math.sin(dLon / 2), 2);
  return 2 * earth * math.asin(math.min(1, math.max(0, h.toDouble())));
}

double _rad(double degrees) => degrees * math.pi / 180;
