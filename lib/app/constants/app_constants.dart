class AppConstants {
  const AppConstants._();

  static const String appName = 'PuneMetro Go';
  static const String tagline = 'Your Pune Metro Companion';
  static const String logoAsset = 'assets/data/PuneMetroGo.png';
  static const String splashAsset = 'assets/data/splash_screen.png';
  static const String databaseName = 'pune_metro.db';
  static const int databaseVersion = 1;
  static const String datasetAsset = 'assets/data/pune_metro_dataset.json';

  static const String estimateMethod =
      'This estimate spreads the line\'s published end-to-end time across the station intervals actually travelled. It is not a timetable arrival and it is not a live prediction.';
}
