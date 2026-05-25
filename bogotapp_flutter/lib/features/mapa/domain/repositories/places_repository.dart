import '../entities/place_entity.dart';

abstract class PlacesRepository {
  Future<List<PlaceEntity>> getAll();
  Future<PlaceEntity> getById(String id);
  Future<PlaceEntity> create({
    required String name,
    required String description,
    required String category,
    required double lat,
    required double lng,
    String? photoPath,
  });
  Future<void> delete(String id);
  Future<({bool liked})> toggleLike(String placeId);
}
