import '../../domain/entities/review_entity.dart';

class ReviewModel {
  final String id;
  final String type;
  final String title;
  final int score;
  final String body;
  final String userId;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.type,
    required this.title,
    required this.score,
    required this.body,
    required this.userId,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        score: json['score'] as int,
        body: json['body'] as String,
        userId: json['userId'] as String,
        createdAt: json['createdAt'] as String,
      );

  ReviewEntity toEntity() => ReviewEntity(
        id: id,
        type: type,
        title: title,
        score: score,
        body: body,
        userId: userId,
        createdAt: DateTime.parse(createdAt),
      );
}
