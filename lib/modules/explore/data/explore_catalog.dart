enum ExploreCategory {
  all,
  historical,
  temple,
  garden,
  shopping,
  museum,
  food,
}

enum ExploreSort { featured, distance, station }

enum ExploreAccess { walk, anotherRide, unknown }

class ExplorePlace {
  const ExplorePlace({
    required this.id,
    required this.name,
    required this.summary,
    required this.description,
    required this.category,
    required this.area,
    required this.address,
    required this.imageAsset,
    required this.latitude,
    required this.longitude,
    required this.popular,
    this.openingHours,
    this.stationCode,
    this.straightLineMetres,
    this.unavailableNote,
  });

  final String id;
  final String name;
  final String summary;
  final String description;
  final ExploreCategory category;
  final String area;
  final String address;
  final String? openingHours;
  final String imageAsset;
  final double latitude;
  final double longitude;
  final bool popular;

  /// Operational station in the stored network. Null when a nearest pin cannot be confirmed.
  final String? stationCode;

  /// Straight-line metres between the OpenStreetMap place pin and the stored station pin.
  final int? straightLineMetres;
  final String? unavailableNote;

  ExploreAccess get access {
    final metres = straightLineMetres;
    if (stationCode == null || metres == null) {
      return ExploreAccess.unknown;
    }
    if (metres <= 1200) {
      return ExploreAccess.walk;
    }
    return ExploreAccess.anotherRide;
  }

  /// Rough guide only. The street walk is usually longer than the straight line.
  int? get roughWalkMinutes {
    final metres = straightLineMetres;
    if (access != ExploreAccess.walk || metres == null) {
      return null;
    }
    final minutes = (metres / 80).round();
    return minutes < 1 ? 1 : minutes;
  }
}

const exploreDistanceNote =
    'Straight-line distance from the station. It is not a street walking route.';

const explorePlaces = <ExplorePlace>[
  ExplorePlace(
    id: 'shaniwar-wada',
    name: 'Shaniwar Wada',
    summary: 'Famous Peshwa-era heritage site.',
    description:
        'Peshwa-era palace fort in the old city. The ramparts and Delhi Gate remain. The buildings inside were lost in the fire of 1828.',
    category: ExploreCategory.historical,
    area: 'Kasba Peth',
    address: 'Shaniwar Wada, Shivaji Road, Kasba Peth, Pune',
    imageAsset: 'assets/explore/shaniwar.jpg',
    latitude: 18.5193826,
    longitude: 73.8553566,
    popular: true,
    stationCode: 'MM-PMC',
    straightLineMetres: 429,
  ),
  ExplorePlace(
    id: 'aga-khan-palace',
    name: 'Aga Khan Palace',
    summary: 'Gandhi memorial and palace architecture.',
    description:
        'Palace in Kalyani Nagar, built in 1892. Mahatma Gandhi, Kasturba Gandhi, and Mahadev Desai were held here during the Quit India Movement.',
    category: ExploreCategory.historical,
    area: 'Kalyani Nagar',
    address: 'Aga Khan Palace, Nagar Road, Kalyani Nagar, Pune',
    imageAsset: 'assets/explore/aga_khan.jpg',
    latitude: 18.5523293,
    longitude: 73.9014785,
    popular: true,
    stationCode: 'MM-RAM',
    straightLineMetres: 911,
  ),
  ExplorePlace(
    id: 'sarasbaug',
    name: 'Sarasbaug Ganpati Temple',
    summary: 'Popular temple and garden near Swargate.',
    description:
        'Ganpati temple and garden at the foot of Parvati Hill. The temple was built in the lake that later became the garden.',
    category: ExploreCategory.temple,
    area: 'Swargate',
    address: 'Sarasbaug, Swargate, Pune',
    imageAsset: 'assets/explore/sarasbaug.jpg',
    latitude: 18.5004949,
    longitude: 73.8529037,
    popular: true,
    stationCode: 'MM-SWG',
    straightLineMetres: 488,
  ),
  ExplorePlace(
    id: 'kelkar-museum',
    name: 'Raja Dinkar Kelkar Museum',
    summary: 'Indian art and historical objects.',
    description:
        'Museum in Shukrawar Peth of everyday Indian art and objects from the collection of Dr Dinkar G. Kelkar.',
    category: ExploreCategory.museum,
    area: 'Shukrawar Peth',
    address: 'Raja Dinkar Kelkar Museum, Shukrawar Peth, Pune',
    imageAsset: 'assets/explore/kelkar.jpg',
    latitude: 18.5107669,
    longitude: 73.854442,
    popular: false,
    unavailableNote:
        'A nearest station is not shown for this place.',
  ),
  ExplorePlace(
    id: 'okayama-garden',
    name: 'Pune Okayama Friendship Garden',
    summary: 'Japanese-style garden on Sinhagad Road.',
    description:
        'Japanese-style garden, also called P. L. Deshpande Garden, in Sahakar Nagar on Sinhagad Road.',
    category: ExploreCategory.garden,
    area: 'Sahakar Nagar',
    address: 'Okayama Friendship Garden, Sahakar Nagar, Pune',
    imageAsset: 'assets/explore/okayama.jpg',
    latitude: 18.4910844,
    longitude: 73.8381503,
    popular: false,
    stationCode: 'MM-NAL',
    straightLineMetres: 2169,
  ),
  ExplorePlace(
    id: 'lal-mahal',
    name: 'Lal Mahal',
    summary: 'Associated with Chhatrapati Shivaji Maharaj.',
    description:
        'Memorial in Kasba Peth linked with the childhood of Chhatrapati Shivaji Maharaj. The building visitors see was rebuilt by the Pune Municipal Corporation.',
    category: ExploreCategory.historical,
    area: 'Kasba Peth',
    address: 'Lal Mahal, Kasba Peth, Pune',
    imageAsset: 'assets/explore/lal_mahal.jpg',
    latitude: 18.518758,
    longitude: 73.8566603,
    popular: true,
    stationCode: 'MM-KBP',
    straightLineMetres: 427,
  ),
];

ExplorePlace? explorePlaceById(String id) {
  for (final place in explorePlaces) {
    if (place.id == id) {
      return place;
    }
  }
  return null;
}

String exploreCategoryLabel(ExploreCategory category) {
  return switch (category) {
    ExploreCategory.all => 'All',
    ExploreCategory.historical => 'Historical Places',
    ExploreCategory.temple => 'Temples',
    ExploreCategory.garden => 'Gardens',
    ExploreCategory.shopping => 'Shopping',
    ExploreCategory.museum => 'Museums',
    ExploreCategory.food => 'Food & Cafes',
  };
}
