import 'package:dio/dio.dart';
import '../../../../core/http/dio_client.dart';

class MoodRecommendation {
  final String type;
  final String name;
  final String reason;
  final double? lat;
  final double? lng;
  final String? category;

  const MoodRecommendation({
    required this.type,
    required this.name,
    required this.reason,
    this.lat,
    this.lng,
    this.category,
  });

  factory MoodRecommendation.fromJson(Map<String, dynamic> json) =>
      MoodRecommendation(
        type: json['type'] as String,
        name: json['name'] as String,
        reason: json['reason'] as String,
        lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
        lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
        category: json['category'] as String?,
      );
}

class MoodRepositoryImpl {
  final Dio _dio;

  MoodRepositoryImpl(DioClient client) : _dio = client.dio;

  Future<MoodRecommendation> getRecommendation(String mood) async {
    try {
      final response = await _dio.post('/mood', data: {'mood': mood});
      return MoodRecommendation.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }
}
