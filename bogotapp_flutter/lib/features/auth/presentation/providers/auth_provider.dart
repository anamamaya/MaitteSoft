import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/http/dio_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(ref.watch(dioClientProvider));
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

const _storage = FlutterSecureStorage();

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final token = await _storage.read(key: 'access_token');
    return token != null ? null : null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUseCaseProvider);
    try {
      final result = await useCase(email, password);
      await _storage.write(key: 'access_token', value: result.accessToken);
      await _storage.write(key: 'refresh_token', value: result.refreshToken);
      state = AsyncData(result.user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    final useCase = ref.read(registerUseCaseProvider);
    try {
      final result = await useCase(name, email, password);
      await _storage.write(key: 'access_token', value: result.accessToken);
      await _storage.write(key: 'refresh_token', value: result.refreshToken);
      state = AsyncData(result.user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await ref.read(authRepositoryProvider).logout(refreshToken);
      } catch (_) {}
    }
    await _storage.deleteAll();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);
