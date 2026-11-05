import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/data/store/firestore_metro_store.dart';
import 'package:pune_metro_guide/data/store/metro_store.dart';
import 'package:pune_metro_guide/data/repositories/admin_repository.dart';
import 'package:pune_metro_guide/data/repositories/alert_repository.dart';
import 'package:pune_metro_guide/data/repositories/fare_repository.dart';
import 'package:pune_metro_guide/data/repositories/metro_repository.dart';
import 'package:pune_metro_guide/data/repositories/timetable_repository.dart';
import 'package:pune_metro_guide/data/repositories/user_repository.dart';
import 'package:pune_metro_guide/data/services/dio_service.dart';
import 'package:pune_metro_guide/data/services/fare_calculator_service.dart';
import 'package:pune_metro_guide/data/services/import_service.dart';
import 'package:pune_metro_guide/data/services/journey_planner_service.dart';
import 'package:pune_metro_guide/data/services/live/metro_live_data_provider.dart';
import 'package:pune_metro_guide/data/services/location_service.dart';
import 'package:pune_metro_guide/data/services/pdf_extraction_service.dart';
import 'package:pune_metro_guide/data/services/web_extraction_service.dart';
import 'package:pune_metro_guide/modules/settings/controllers/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences, permanent: true);
    final logger = AppLogger();
    final deviceId = await _deviceId(preferences);
    final MetroStore store = FirestoreMetroStore(FirebaseFirestore.instance, deviceId: deviceId);
    Get.put(logger, permanent: true);
    Get.put(store, permanent: true);
    Get.put(DioService(), permanent: true);
    Get.put(ImportService(store, logger), permanent: true);
    Get.put(MetroRepository(store), permanent: true);
    Get.put(TimetableRepository(store), permanent: true);
    Get.put(FareRepository(store), permanent: true);
    Get.put(UserRepository(store), permanent: true);
    Get.put(AlertRepository(store), permanent: true);
    Get.put(AdminRepository(store), permanent: true);
    Get.put(WebExtractionService(Get.find(), logger), permanent: true);
    Get.put(PdfExtractionService(Get.find()), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(const JourneyPlannerService(), permanent: true);
    Get.put(const FareCalculatorService(), permanent: true);
    Get.put<MetroLiveDataProvider>(const NoLiveFeedConnected(), permanent: true);
    Get.put(ThemeController(preferences), permanent: true);
  }

  static Future<String> _deviceId(SharedPreferences preferences) async {
    final saved = preferences.getString('device_id');
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    final random = Random.secure();
    final id = List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await preferences.setString('device_id', id);
    return id;
  }
}
