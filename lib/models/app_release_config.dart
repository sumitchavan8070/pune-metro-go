class AppReleaseConfig {
  const AppReleaseConfig({
    required this.softUpdate,
    required this.forceUpdate,
    required this.serverMaintenance,
    required this.version,
    required this.title,
    required this.message,
    required this.playStoreUrl,
    required this.appStoreUrl,
    required this.localBuild,
  });

  final bool softUpdate;
  final bool forceUpdate;
  final bool serverMaintenance;
  final int version;
  final String title;
  final String message;
  final String playStoreUrl;
  final String appStoreUrl;
  final int localBuild;

  bool get needsUpdate => version > localBuild;

  bool get showForce => forceUpdate && needsUpdate;

  bool get showSoft => !showForce && !serverMaintenance && softUpdate && needsUpdate;

  static AppReleaseConfig inactive(int localBuild) {
    return AppReleaseConfig(
      softUpdate: false,
      forceUpdate: false,
      serverMaintenance: false,
      version: 0,
      title: '',
      message: '',
      playStoreUrl: '',
      appStoreUrl: '',
      localBuild: localBuild,
    );
  }

  factory AppReleaseConfig.fromMap(Map<String, dynamic> data, int localBuild) {
    return AppReleaseConfig(
      softUpdate: _flag(data['softupdate']),
      forceUpdate: _flag(data['forceupdate']),
      serverMaintenance: _flag(data['servermaintance']),
      version: _number(data['version']),
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      playStoreUrl: data['playstoreurl'] as String? ?? '',
      appStoreUrl: data['appstoreurl'] as String? ?? '',
      localBuild: localBuild,
    );
  }

  String titleFor({required bool maintenance}) {
    final value = title.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return maintenance ? 'Server maintenance' : 'Update available';
  }

  String messageFor({required bool maintenance}) {
    final value = message.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return maintenance
        ? 'PuneMetro Go is unavailable right now. Please try again later.'
        : 'A newer version of PuneMetro Go is ready.';
  }
}

bool _flag(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = value?.toString().trim().toLowerCase();
  return text == '1' || text == 'true';
}

int _number(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
