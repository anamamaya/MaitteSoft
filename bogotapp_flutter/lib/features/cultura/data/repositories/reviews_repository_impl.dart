import 'package:dio/dio.dart';
import '../../../../core/http/dio_client.dart';
import '../../domain/entities/review_entity.dart';
import '../models/review_model.dart';

class ReviewsRepositoryImpl {
  final Dio _dio;

  ReviewsRepositoryImpl(DioClient client) : _dio = client.dio;

  Future<List<ReviewEntity>> getAll({String? type}) async {
    try {
      final response = await _dio.get(
        '/reviews',
        queryParameters: type != null ? {'type': type} : null,
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) =>
              ReviewModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  Future<ReviewEntity> create({
    required String type,
    required String title,
    required int score,
    required String body,
  }) async {
    try {
      final response = await _dio.post('/reviews', data: {
        'type': type,
        'title': title,
        'score': score,
        'body': body,
      });
      return ReviewModel.fromJson(
              response.data['data'] as Map<String, dynamic>)
          .toEntity();
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('/reviews/$id');
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }
}
