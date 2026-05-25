import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({UserEntity user, String accessToken, String refreshToken})> login(
      String email, String password);

  Future<({UserEntity user, String accessToken, String refreshToken})> register(
      String name, String email, String password);

  Future<({String accessToken, String refreshToken})> refresh(
      String refreshToken);

  Future<void> logout(String refreshToken);
}
