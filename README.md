# Pune Metro Guide

Passenger guide for the Pune Metro. Reference data is stored in Cloud Firestore and cached on the phone. The app does not invent train numbers, per-station departure times, fares, or live positions.

## Run

```bash
flutter pub get
flutter run
```

The first launch imports `assets/data/pune_metro_dataset.json` into Firestore when the saved dataset version differs. Publish `firestore.rules` in the punemetro-go project before that first load. Android uses `android/app/google-services.json`. iOS still needs `GoogleService-Info.plist`.

Checks:

```bash
flutter analyze
flutter test
```

## Refresh the reference data

Rebuild the reviewed dataset after you edit `tool/build_dataset.py`:

```bash
python3 tool/build_dataset.py
dart run tool/import_metro_data.dart
```

Check that the public pages still contain the phrases recorded with the dataset. This does not overwrite the phone database:

```bash
dart run tool/import_metro_data.dart --check-urls
```

On a phone:

- A newer bundled dataset is imported on launch when its version differs from the copy in Firestore.
- Tap the app version seven times to open Data management. That screen can import a reviewed JSON file, re-check public pages, review conflicts, and save a manual station-status correction. Manual corrections are kept when a later import is weaker.

## Packages

- `get` — navigation, dependency injection, and controller state.
- `firebase_core` and `cloud_firestore` — metro data, favourites, and recent journeys.
- `dio` — public page and document-header checks. It is not used to call a private API.
- `shared_preferences` — theme mode only.
- `google_maps_flutter` — city map. Android reads `com.google.android.geo.API_KEY` from the app manifest.
- `geolocator` — one-shot nearby search after the passenger asks for it.
- `file_picker` — import a replacement dataset JSON.
- `intl` — dates.
- `package_info_plus` — version shown in Settings.

## Data store

Cloud Firestore holds the same collections the app used as tables: operators, sources, stations, lines, line stations, aliases, facilities, timetables, fares, interchanges, alerts, favourites, recent journeys, conflicts, import logs, and meta. Imports stay in one batch. A station marked manually corrected is not overwritten. Firestore offline persistence keeps a cache on the phone.

## Data snapshot `2026.11.04.1`

Extracted 4 November 2026.

| Item | Count |
| --- | --- |
| Operators | 2 |
| Lines | 9 |
| Stations | 72 |
| Open or reported open | 45 unique stations |
| Not in passenger service | 27 |
| Timetable rows | 4 (2 current, 2 expired Ganeshotsav notices) |
| Station-by-station departures | 0 |
| Fares | 0 |
| Open conflicts | 14 |
| Stations without coordinates | District Court, Mandai, Ideal Colony, Mangalwar Peth, Pune Railway Station |

Maha Metro's homepage count of 29 operational stations counts Purple and Aqua separately, so District Court is counted twice and Range Hill is the one not marked open. The database stores District Court once, which is 28 unique stations marked operational from that official reading, plus 17 Line 3 stations marked reported open from a secondary report.

## Sources

Official pages read on 4 November 2026:

- https://www.punemetrorail.org/
- https://www.punemetrorail.org/project-profile
- https://www.punemetrorail.org/route-map?lang=en-US
- https://www.punemetrorail.org/time-table and the English and Marathi images linked there, effective 15 August 2025
- https://www.punemetrorail.org/Line_b.aspx
- https://www.punemetrorail.org/Line_2a_b.aspx
- https://www.punemetrorail.org/Line_4a_b.aspx
- https://www.pmrda.gov.in/en/pune-metro-line-3/
- https://punerimetro.in/route/station-list

`robots.txt` on those hosts allowed the public pages that were fetched. The fare form at `fare_chart.aspx` uses a CAPTCHA and was not extracted.

Secondary, and labelled as such:

- Free Press Journal, 3 November 2026, for which Line 3 stations were reported open on 4 November 2026. Fares and headways in that article were not imported.
- Siemens Mobility press release, 3 November 2026, confirming that Line 3 passenger operations had commenced. It does not list closed stations.
- OpenStreetMap, for coordinates where a node name matched a station. Community coordinates are not an operator survey. Pins that were ambiguous were left empty.

Not used as current data:

- The April 2023 PCMC–Phugewadi priority-section PDF.
- The March 2024 commuter guide, because it still describes later sections as unopened and prints an older fare range.

## What the app will not show

- A verified station-to-station fare. The calculator says the fare is unavailable.
- A departure minute at each station. Headways are shown as published frequencies only.
- A Line 3 duration. No official end-to-end time was found.
- Live train positions. `MetroLiveDataProvider` throws until an authorised feed is connected.
- Station facilities as if each station had been inspected. Line 3's line-wide claims stay on the line page.
# pune-metro-go
