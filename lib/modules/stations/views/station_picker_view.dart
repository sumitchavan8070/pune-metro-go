import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/widgets/pm_feedback.dart';
import 'package:pune_metro_guide/app/widgets/pm_search_field.dart';
import 'package:pune_metro_guide/app/widgets/pm_station_tile.dart';
import 'package:pune_metro_guide/modules/stations/controllers/station_controller.dart';

class StationPickerView extends GetView<StationPickerController> {
  const StationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final selecting = Get.arguments == 'pick';
    return Scaffold(
      appBar: AppBar(title: Text(selecting ? 'Choose a station' : 'Stations')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            children: [
              PmSearchField(controller: controller.searchController, onChanged: controller.search),
              const SizedBox(height: 8),
              Expanded(
                child: controller.loading.value
                    ? const PmLoadingSkeleton()
                    : ListView.builder(
                        itemCount: controller.results.length,
                        itemBuilder: (context, index) {
                          final station = controller.results[index];
                          return PmStationTile(
                            station: station,
                            onTap: () {
                              if (selecting) {
                                Get.back(result: station);
                              } else {
                                Get.toNamed('/stations/${station.id}');
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
