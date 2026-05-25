import 'package:dio/dio.dart';
import '../../../../core/http/dio_client.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../models/place_model.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final Dio _dio;

  PlacesRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<PlaceEntity>> getAll() async {
    try {
      final response = await _dio.get('/places');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<PlaceEntity> getById(String id) async {
    try {
      final response = await _dio.get('/places/$id');
      return PlaceModel.fromJson(
              response.data['data'] as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<PlaceEntity> create({
    required String name,
    required String description,
    required String category,
    required double lat,
    required double lng,
    String? photoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'category': category,
        'lat': lat.toString(),
        'lng': lng.toString(),
        if (photoPath != null)
          'photo': await MultipartFile.fromFile(photoPath),
      });

      final response = await _dio.post(
        '/places',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return PlaceModel.fromJson(
              response.data['data'] as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/places/$id');
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<({bool liked})> toggleLike(String placeId) async {
    try {
      final response = await _dio.post('/places/$placeId/likes');
      final liked = response.data['data']['liked'] as bool;
      return (liked: liked);
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }
}
