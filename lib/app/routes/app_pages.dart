import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/modules/alerts/bindings/alerts_binding.dart';
import 'package:pune_metro_guide/modules/alerts/views/alerts_view.dart';
import 'package:pune_metro_guide/modules/developer/bindings/developer_binding.dart';
import 'package:pune_metro_guide/modules/developer/views/developer_view.dart';
import 'package:pune_metro_guide/modules/fare_calculator/bindings/fare_binding.dart';
import 'package:pune_metro_guide/modules/fare_calculator/views/fare_view.dart';
import 'package:pune_metro_guide/modules/metro_lines/bindings/line_binding.dart';
import 'package:pune_metro_guide/modules/metro_lines/views/line_detail_view.dart';
import 'package:pune_metro_guide/modules/metro_lines/views/line_list_view.dart';
import 'package:pune_metro_guide/modules/settings/bindings/settings_binding.dart';
import 'package:pune_metro_guide/modules/settings/views/settings_view.dart';
import 'package:pune_metro_guide/modules/shell/bindings/shell_binding.dart';
import 'package:pune_metro_guide/modules/shell/views/shell_view.dart';
import 'package:pune_metro_guide/modules/splash/bindings/splash_binding.dart';
import 'package:pune_metro_guide/modules/splash/views/splash_view.dart';
import 'package:pune_metro_guide/modules/stations/bindings/station_binding.dart';
import 'package:pune_metro_guide/modules/stations/views/station_detail_view.dart';
import 'package:pune_metro_guide/modules/stations/views/station_picker_view.dart';
import 'package:pune_metro_guide/modules/timetable/bindings/timetable_binding.dart';
import 'package:pune_metro_guide/modules/timetable/views/timetable_view.dart';

class AppPages {
  const AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: AppRoutes.shell, page: () => const ShellView(), binding: ShellBinding()),
    GetPage(name: AppRoutes.lines, page: () => const LineListView(), binding: LineListBinding()),
    GetPage(name: AppRoutes.line, page: () => const LineDetailView(), binding: LineDetailBinding()),
    GetPage(name: AppRoutes.station, page: () => const StationDetailView(), binding: StationDetailBinding()),
    GetPage(name: AppRoutes.pickStation, page: () => StationPickerView(), binding: StationPickerBinding()),
    GetPage(name: AppRoutes.timetable, page: () => const TimetableView(), binding: TimetableBinding()),
    GetPage(name: AppRoutes.fares, page: () => const FareView(), binding: FareBinding()),
    GetPage(name: AppRoutes.alerts, page: () => const AlertsView(), binding: AlertsBinding()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView(), binding: SettingsBinding()),
    GetPage(name: AppRoutes.developer, page: () => const DeveloperView(), binding: DeveloperBinding()),
  ];
}
