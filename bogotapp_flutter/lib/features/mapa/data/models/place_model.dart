import '../../domain/entities/place_entity.dart';

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String lat;
  final String lng;
  final String? photoUrl;
  final int likesCount;
  final String userId;
  final String createdAt;

  const PlaceModel({
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

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        lat: json['lat'].toString(),
        lng: json['lng'].toString(),
        photoUrl: json['photoUrl'] as String?,
        likesCount: json['likesCount'] as int? ?? 0,
        userId: json['userId'] as String,
        createdAt: json['createdAt'] as String,
      );

  PlaceEntity toEntity() => PlaceEntity(
        id: id,
        name: name,
        description: description,
        category: category,
        lat: double.parse(lat),
        lng: double.parse(lng),
        photoUrl: photoUrl,
        likesCount: likesCount,
        userId: userId,
        createdAt: DateTime.parse(createdAt),
      );
}
