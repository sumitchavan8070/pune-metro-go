class RecentJourneyModel {
  const RecentJourneyModel({
    required this.id,
    required this.originStationId,
    required this.destinationStationId,
    required this.createdAt,
    this.journeyDate,
    this.originName,
    this.destinationName,
  });

  final int id;
  final int originStationId;
  final int destinationStationId;
  final String? journeyDate;
  final String createdAt;
  final String? originName;
  final String? destinationName;

  factory RecentJourneyModel.fromMap(Map<String, Object?> row) {
    return RecentJourneyModel(
      id: row['id'] as int,
      originStationId: row['origin_station_id'] as int,
      destinationStationId: row['destination_station_id'] as int,
      journeyDate: row['journey_date'] as String?,
      createdAt: row['created_at'] as String,
      originName: row['origin_name'] as String?,
      destinationName: row['destination_name'] as String?,
    );
  }
}

class FavouriteModel {
  const FavouriteModel({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.createdAt,
    this.originStationId,
    this.destinationStationId,
    this.label,
    this.detail,
  });

  final int id;
  final String itemType;
  final int itemId;
  final int? originStationId;
  final int? destinationStationId;
  final String createdAt;
  final String? label;
  final String? detail;

  factory FavouriteModel.fromMap(Map<String, Object?> row) {
    return FavouriteModel(
      id: row['id'] as int,
      itemType: row['item_type'] as String,
      itemId: row['item_id'] as int,
      originStationId: row['origin_station_id'] as int?,
      destinationStationId: row['destination_station_id'] as int?,
      createdAt: row['created_at'] as String,
      label: row['label'] as String?,
      detail: row['detail'] as String?,
    );
  }
}
