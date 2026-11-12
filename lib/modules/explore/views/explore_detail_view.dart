import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_buttons.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/modules/explore/controllers/explore_controller.dart';
import 'package:pune_metro_guide/modules/explore/data/explore_catalog.dart';

class ExploreDetailView extends GetView<ExploreDetailController> {
  const ExploreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreDetailController>(
      builder: (controller) {
        final place = controller.place;
        if (place == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Explore Pune')),
            body: const PmEmptyState(title: 'Place not found', message: 'This destination is not in the saved list.'),
          );
        }
        final brightness = Theme.of(context).brightness;
        final muted = AppColors.textSecondary(brightness);
        final link = controller.link;
        final station = link?.station;
        final line = link?.line;
        return Scaffold(
          appBar: AppBar(title: Text(place.name)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.asset(
                  place.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.primaryPurpleLight,
                    child: Center(child: Icon(Icons.photo_outlined, color: AppColors.primaryPurple, size: 36)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exploreCategoryLabel(place.category), style: AppTextStyles.caption.copyWith(color: AppColors.primary(brightness))),
                    const SizedBox(height: 4),
                    Text(place.name, style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 8),
                    Text(place.description, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    Text('Address', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(place.address, style: AppTextStyles.bodySmall.copyWith(color: muted)),
                    if (place.openingHours != null) ...[
                      const SizedBox(height: 12),
                      Text('Opening hours', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(place.openingHours!, style: AppTextStyles.bodySmall.copyWith(color: muted)),
                    ],
                    const SizedBox(height: 16),
                    Material(
                      color: AppColors.surface(brightness),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        side: BorderSide(color: AppColors.border(brightness)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From the metro', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            if (station == null)
                              Text(
                                place.unavailableNote ?? 'A nearest station is not confirmed for this place.',
                                style: AppTextStyles.bodySmall.copyWith(color: muted),
                              )
                            else ...[
                              Text(station.name, style: AppTextStyles.titleLarge),
                              if (line != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(line.name, style: AppTextStyles.bodySmall.copyWith(color: lineColor(line.color))),
                                ),
                              if (place.straightLineMetres != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${formatDistanceMetres(place.straightLineMetres!.toDouble())} in a straight line',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(exploreDistanceNote, style: AppTextStyles.caption.copyWith(color: muted)),
                              ],
                              const SizedBox(height: 8),
                              Text(_accessCopy(place), style: AppTextStyles.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PmSecondaryButton(
                            label: 'View on map',
                            icon: Icons.map_outlined,
                            onPressed: () => controller.openMap(directions: false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PmPrimaryButton(
                            label: 'Get directions',
                            icon: Icons.directions_walk,
                            onPressed: station?.hasCoordinates == true
                                ? () => controller.openMap(directions: true)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (station?.hasCoordinates != true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Directions are not available for this place.',
                          style: AppTextStyles.caption.copyWith(color: muted),
                        ),
                      ),
                    Obx(() {
                      if (!controller.showMap.value) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: SizedBox(
                            height: 260,
                            child: _PlaceMap(
                              place: place,
                              link: link,
                              fitBoth: controller.fitBoth.value,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _accessCopy(ExplorePlace place) {
    final minutes = place.roughWalkMinutes;
    return switch (place.access) {
      ExploreAccess.walk when minutes != null =>
        'A short walk may be possible. About $minutes min is only a rough guide from the straight line, and the street walk is usually longer.',
      ExploreAccess.anotherRide =>
        'This is too far for a short walk. Another ride is the practical way from the station.',
      _ => 'How to get there from the station is not confirmed.',
    };
  }
}

class _PlaceMap extends StatefulWidget {
  const _PlaceMap({required this.place, required this.link, required this.fitBoth});

  final ExplorePlace place;
  final ExploreStationLink? link;
  final bool fitBoth;

  @override
  State<_PlaceMap> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<_PlaceMap> {
  GoogleMapController? _map;

  LatLng get _placePoint => LatLng(widget.place.latitude, widget.place.longitude);

  LatLng? get _stationPoint {
    final station = widget.link?.station;
    if (station == null || !station.hasCoordinates) {
      return null;
    }
    return LatLng(station.latitude!, station.longitude!);
  }

  Future<void> _frame() async {
    final map = _map;
    if (map == null) {
      return;
    }
    final station = _stationPoint;
    if (!widget.fitBoth || station == null) {
      await map.animateCamera(CameraUpdate.newLatLngZoom(_placePoint, 15));
      return;
    }
    final south = _placePoint.latitude < station.latitude ? _placePoint.latitude : station.latitude;
    final north = _placePoint.latitude > station.latitude ? _placePoint.latitude : station.latitude;
    final west = _placePoint.longitude < station.longitude ? _placePoint.longitude : station.longitude;
    final east = _placePoint.longitude > station.longitude ? _placePoint.longitude : station.longitude;
    try {
      await map.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
          48,
        ),
      );
    } catch (_) {
      await map.animateCamera(CameraUpdate.newLatLngZoom(_placePoint, 14));
    }
  }

  @override
  void didUpdateWidget(covariant _PlaceMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fitBoth != widget.fitBoth) {
      _frame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final station = _stationPoint;
    final line = widget.link?.line;
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _placePoint, zoom: 15),
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
      onMapCreated: (controller) {
        _map = controller;
        _frame();
      },
      markers: {
        Marker(markerId: const MarkerId('place'), position: _placePoint, infoWindow: InfoWindow(title: widget.place.name)),
        if (station != null)
          Marker(
            markerId: const MarkerId('station'),
            position: station,
            infoWindow: InfoWindow(title: widget.link!.station.name),
          ),
      },
      polylines: {
        if (widget.fitBoth && station != null)
          Polyline(
            polylineId: const PolylineId('straight'),
            points: [_placePoint, station],
            width: 4,
            color: line == null ? AppColors.primaryPurple : lineColor(line.color),
          ),
      },
    );
  }
}
