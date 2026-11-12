import 'package:flutter/foundation.dart';
import 'package:pune_metro_guide/models/app_release_config.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openStoreListing(AppReleaseConfig config) async {
  final raw = defaultTargetPlatform == TargetPlatform.iOS ? config.appStoreUrl : config.playStoreUrl;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
