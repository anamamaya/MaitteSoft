import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<({UserEntity user, String accessToken, String refreshToken})> call(
      String name, String email, String password) {
    return _repository.register(name, email, password);
  }
}
