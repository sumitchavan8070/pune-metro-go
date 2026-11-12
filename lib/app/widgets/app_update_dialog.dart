import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/utils/store_link.dart';
import 'package:pune_metro_guide/models/app_release_config.dart';

Future<void> showAppUpdateDialog(AppReleaseConfig config, {required bool force}) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) {
    return Future.value();
  }
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: !force,
        child: CupertinoAlertDialog(
          title: Text(config.titleFor(maintenance: false)),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(config.messageFor(maintenance: false)),
          ),
          actions: [
            if (!force)
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => openStoreListing(config),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    },
  );
}
