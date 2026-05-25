class ReviewEntity {
  final String id;
  final String type;
  final String title;
  final int score;
  final String body;
  final String userId;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.score,
    required this.body,
    required this.userId,
    required this.createdAt,
  });
}
