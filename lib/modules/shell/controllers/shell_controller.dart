import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/widgets/app_update_dialog.dart';
import 'package:pune_metro_guide/data/services/app_release_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShellController extends GetxController {
  static const disclaimerSeenKey = 'cupertino_disclaimer_seen';

  final index = 0.obs;
  late final SharedPreferences _preferences = Get.find<SharedPreferences>();
  late final showDisclaimer = (!(_preferences.getBool(disclaimerSeenKey) ?? false)).obs;
  bool _dialogScheduled = false;

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presentStartupPrompts());
  }

  Future<void> _presentStartupPrompts() async {
    final release = Get.find<AppReleaseService>().latest;
    if (release != null && release.showSoft) {
      await showAppUpdateDialog(release, force: false);
    }
    if (!showDisclaimer.value || _dialogScheduled) {
      return;
    }
    _dialogScheduled = true;
    _presentDisclaimer();
  }

  void select(int value) => index.value = value;

  Future<void> dismissDisclaimer() async {
    showDisclaimer.value = false;
    await _preferences.setBool(disclaimerSeenKey, true);
  }

  void _presentDisclaimer() {
    final context = Get.overlayContext ?? Get.context;
    if (context == null || !showDisclaimer.value) {
      return;
    }
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Disclaimer'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'PuneMetro Go is an independent guide. It is not the official Maha Metro or Pune Metro app. This app does not sell tickets and does not show live trains.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    ).whenComplete(dismissDisclaimer);
  }
}
