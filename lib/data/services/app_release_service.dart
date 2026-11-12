import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/models/app_release_config.dart';

class AppReleaseService {
  AppReleaseService(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;
  AppReleaseConfig? latest;

  static const collection = 'app_maintance';
  static const documentId = 'config';

  Future<AppReleaseConfig> load() async {
    final info = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(info.buildNumber) ?? 0;
    try {
      final snapshot = await _firestore.collection(collection).doc(documentId).get();
      if (!snapshot.exists) {
        latest = AppReleaseConfig.inactive(localBuild);
        return latest!;
      }
      latest = AppReleaseConfig.fromMap(snapshot.data() ?? {}, localBuild);
      return latest!;
    } catch (error, stackTrace) {
      _logger.error(
        'App maintenance document could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      latest = AppReleaseConfig.inactive(localBuild);
      return latest!;
    }
  }
}
