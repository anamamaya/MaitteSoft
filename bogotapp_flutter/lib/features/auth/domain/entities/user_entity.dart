class UserEntity {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
}
