class PlaceEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final double lat;
  final double lng;
  final String? photoUrl;
  final int likesCount;
  final String userId;
  final DateTime createdAt;

  const PlaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.lat,
    required this.lng,
    this.photoUrl,
    required this.likesCount,
    required this.userId,
    required this.createdAt,
  });
}
