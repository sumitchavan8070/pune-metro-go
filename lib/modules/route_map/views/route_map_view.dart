import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_interchange_badge.dart';
import 'package:pune_metro_guide/models/metro_line_model.dart';
import 'package:pune_metro_guide/models/route_model.dart';
import 'package:pune_metro_guide/models/station_model.dart';
import 'package:pune_metro_guide/modules/journey_planner/controllers/journey_planner_controller.dart';
import 'package:pune_metro_guide/modules/route_map/controllers/route_map_controller.dart';

class RouteMapView extends GetView<RouteMapController> {
  const RouteMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.loading.value) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.screenPadding),
            child: PmLoadingSkeleton(),
          );
        }
        final line = controller.selectedLine;
        final stations = controller.selectedStations;
        final selectedStationId = controller.selectedStationId.value;
        final plan = _highlightedPlan();
        final brightness = Theme.of(context).brightness;
        final muted = AppColors.textSecondary(brightness);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text('Metro Map', style: AppTextStyles.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'One line at a time. Numbers follow the route from the start.',
                style: AppTextStyles.bodySmall.copyWith(color: muted),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.lines.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = controller.lines[index];
                  final selected = item.id == controller.selectedLineId.value;
                  final color = lineColor(item.color);
                  return ChoiceChip(
                    label: Text(item.name),
                    selected: selected,
                    showCheckmark: false,
                    avatar: CircleAvatar(backgroundColor: color, radius: 6),
                    selectedColor: color.withValues(alpha: 0.16),
                    labelStyle: AppTextStyles.labelLarge.copyWith(
                      color: selected ? color : AppColors.textPrimary(brightness),
                    ),
                    side: BorderSide(color: selected ? color : AppColors.border(brightness)),
                    onSelected: (_) => controller.selectLine(item.id),
                  );
                },
              ),
            ),
            if (line != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LineSummary(line: line, stationCount: stations.length),
              ),
            ],
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Station list'), icon: Icon(Icons.format_list_numbered)),
                  ButtonSegment(value: true, label: Text('City map'), icon: Icon(Icons.map_outlined)),
                ],
                selected: {controller.geographic.value},
                onSelectionChanged: (value) => controller.geographic.value = value.first,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: line == null
                  ? const PmEmptyState(title: 'No lines stored', message: 'The saved metro data has no lines to show.')
                  : stations.isEmpty
                      ? const PmEmptyState(
                          title: 'No stations published',
                          message: 'This corridor has no station list in the stored data.',
                          icon: Icons.route,
                        )
                      : controller.geographic.value
                          ? _CityMap(
                              line: line,
                              stations: stations,
                              plan: plan,
                              controller: controller,
                              selectedId: selectedStationId,
                            )
                          : _StationList(line: line, stations: stations, plan: plan, controller: controller),
            ),
          ],
        );
      }),
    );
  }

  JourneyPlan? _highlightedPlan() {
    if (!Get.isRegistered<JourneyPlannerController>()) {
      return null;
    }
    for (final plan in Get.find<JourneyPlannerController>().plans) {
      if (plan.success) {
        return plan;
      }
    }
    return null;
  }
}

class _LineSummary extends StatelessWidget {
  const _LineSummary({required this.line, required this.stationCount});

  final MetroLineModel line;
  final int stationCount;

  @override
  Widget build(BuildContext context) {
    final color = lineColor(line.color);
    final muted = AppColors.textSecondary(Theme.of(context).brightness);
    return Row(
      children: [
        Container(width: 6, height: 42, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${line.originName ?? 'Origin unpublished'}  →  ${line.destinationName ?? 'Destination unpublished'}',
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stationCount == 0 ? 'No stations stored' : '$stationCount stations, in route order',
                style: AppTextStyles.caption.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({
    required this.line,
    required this.stations,
    required this.plan,
    required this.controller,
  });

  final MetroLineModel line;
  final List<StationModel> stations;
  final JourneyPlan? plan;
  final RouteMapController controller;

  @override
  Widget build(BuildContext context) {
    final color = lineColor(line.color);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final selected = controller.selectedStationId.value == station.id;
        final onRoute = plan?.stationIds.contains(station.id) ?? false;
        return _StationRow(
          index: index,
          count: stations.length,
          station: station,
          color: color,
          selected: selected,
          onRoute: onRoute,
          onSelect: () => controller.selectStation(station.id),
          onOpen: () => Get.toNamed('/stations/${station.id}'),
        );
      },
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.index,
    required this.count,
    required this.station,
    required this.color,
    required this.selected,
    required this.onRoute,
    required this.onSelect,
    required this.onOpen,
  });

  final int index;
  final int count;
  final StationModel station;
  final Color color;
  final bool selected;
  final bool onRoute;
  final VoidCallback onSelect;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(brightness);
    final status = operationalStatus(station.operationalStatus).label;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Expanded(child: Container(width: 3, color: index == 0 ? Colors.transparent : color)),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? color : AppColors.surface(brightness),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.caption.copyWith(color: selected ? AppColors.white : color),
                      ),
                    ),
                    Expanded(child: Container(width: 3, color: index == count - 1 ? Colors.transparent : color)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.12) : AppColors.surface(brightness),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: selected ? color : AppColors.border(brightness)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(station.name, style: AppTextStyles.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (index == 0) 'Start',
                                if (index == count - 1) 'End',
                                status,
                                if (station.aliasNames.isNotEmpty) 'Also called ${station.aliasNames.join(', ')}',
                                if (!station.isBoardable) 'Not open for boarding',
                                if (onRoute) 'On your planned route',
                                if (!station.hasCoordinates) 'No city-map pin',
                              ].join(' · '),
                              style: AppTextStyles.caption.copyWith(color: muted),
                            ),
                            if (station.isInterchange) ...[
                              const SizedBox(height: 6),
                              const PmInterchangeBadge(),
                            ],
                          ],
                        ),
                      ),
                      TextButton(onPressed: onOpen, child: const Text('Open')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityMap extends StatefulWidget {
  const _CityMap({
    required this.line,
    required this.stations,
    required this.plan,
    required this.controller,
    required this.selectedId,
  });

  final MetroLineModel line;
  final List<StationModel> stations;
  final JourneyPlan? plan;
  final RouteMapController controller;
  final int? selectedId;

  @override
  State<_CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<_CityMap> {
  final _pins = <String, BitmapDescriptor>{};
  GoogleMapController? _map;
  var _markers = <Marker>{};
  var _markerGeneration = 0;

  List<LatLng> get _points => [
        for (final station in widget.stations)
          if (station.hasCoordinates) LatLng(station.latitude!, station.longitude!),
      ];

  StationModel? get _selected {
    for (final station in widget.stations) {
      if (station.id == widget.selectedId) {
        return station;
      }
    }
    return widget.stations.isEmpty ? null : widget.stations.first;
  }

  @override
  void initState() {
    super.initState();
    _refreshMarkers();
  }

  Future<void> _fit() async {
    final map = _map;
    final points = _points;
    if (map == null || points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      await map.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    try {
      await map.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
          48,
        ),
      );
    } catch (_) {
      await map.animateCamera(CameraUpdate.newLatLngZoom(points.first, 12));
    }
  }

  Future<void> _moveToSelected() async {
    final map = _map;
    final station = _selected;
    if (map == null || station == null || !station.hasCoordinates) {
      return;
    }
    await map.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(station.latitude!, station.longitude!), 14),
    );
  }

  Future<void> _refreshMarkers() async {
    final generation = ++_markerGeneration;
    final color = lineColor(widget.line.color);
    final markers = <Marker>{};
    for (var index = 0; index < widget.stations.length; index++) {
      final station = widget.stations[index];
      if (!station.hasCoordinates) {
        continue;
      }
      final selected = station.id == widget.selectedId;
      final onRoute = widget.plan?.stationIds.contains(station.id) ?? false;
      final icon = await _pin(index + 1, color, selected || onRoute);
      if (!mounted || generation != _markerGeneration) {
        return;
      }
      markers.add(
        Marker(
          markerId: MarkerId('${station.id}'),
          position: LatLng(station.latitude!, station.longitude!),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: selected ? 2 : 1,
          onTap: () => widget.controller.selectStation(station.id),
        ),
      );
    }
    if (!mounted || generation != _markerGeneration) {
      return;
    }
    setState(() => _markers = markers);
  }

  Future<BitmapDescriptor> _pin(int number, Color color, bool filled) async {
    final key = '$number-${color.toARGB32()}-$filled';
    final cached = _pins[key];
    if (cached != null) {
      return cached;
    }
    const logical = 34.0;
    const pixelRatio = 3.0;
    final size = (logical * pixelRatio).round();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - pixelRatio * 2;
    canvas.drawCircle(center, radius, Paint()..color = filled ? color : AppColors.white);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = pixelRatio * 2,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: filled ? AppColors.white : color,
          fontSize: pixelRatio * 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: logical,
      height: logical,
    );
    _pins[key] = descriptor;
    return descriptor;
  }

  @override
  void didUpdateWidget(covariant _CityMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final lineChanged = oldWidget.line.id != widget.line.id;
    final selectionChanged = oldWidget.selectedId != widget.selectedId;
    final planChanged = oldWidget.plan?.stationIds.join() != widget.plan?.stationIds.join();
    if (lineChanged || selectionChanged || planChanged) {
      _refreshMarkers();
    }
    if (lineChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fit();
        }
      });
      return;
    }
    if (selectionChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _moveToSelected();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = lineColor(widget.line.color);
    final points = _points;
    final selected = _selected;
    final selectedIndex = selected == null ? -1 : widget.stations.indexWhere((station) => station.id == selected.id);
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Expanded(
          child: points.isEmpty
              ? const PmEmptyState(
                  title: 'No pins for this line',
                  message: 'None of these stations have a stored coordinate. Their names are in the station list.',
                  icon: Icons.location_off_outlined,
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: points.first, zoom: 12),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _map = controller;
                    _fit();
                  },
                  markers: _markers,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId('line-${widget.line.id}'),
                      points: points,
                      color: color,
                      width: 5,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                  },
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: true,
                ),
        ),
        if (selected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Material(
              color: AppColors.surface(brightness),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: BorderSide(color: color, width: 1.4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous station',
                      onPressed: selectedIndex <= 0 ? null : () => widget.controller.stepStation(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Text(
                        '${selectedIndex + 1}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selected.name, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                            [
                              selectedIndex == 0
                                  ? 'Start of this line'
                                  : selectedIndex == widget.stations.length - 1
                                      ? 'End of this line'
                                      : 'Stop ${selectedIndex + 1} of ${widget.stations.length}',
                              if (selected.aliasNames.isNotEmpty) 'Also called ${selected.aliasNames.join(', ')}',
                            ].join(' · '),
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary(brightness)),
                          ),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () => Get.toNamed('/stations/${selected.id}'), child: const Text('Open')),
                    IconButton(
                      tooltip: 'Next station',
                      onPressed: selectedIndex < 0 || selectedIndex >= widget.stations.length - 1
                          ? null
                          : () => widget.controller.stepStation(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
