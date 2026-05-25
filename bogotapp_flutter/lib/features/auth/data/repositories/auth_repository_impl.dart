import 'package:dio/dio.dart';
import '../../../../core/http/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(DioClient client) : _dio = client.dio;

  @override
  Future<({UserEntity user, String accessToken, String refreshToken})> login(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final model = AuthResponseModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return (
        user: model.user.toEntity(),
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<({UserEntity user, String accessToken, String refreshToken})> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      final model = AuthResponseModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return (
        user: model.user.toEntity(),
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<({String accessToken, String refreshToken})> refresh(
      String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return (
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw dioExceptionToFailure(e);
    }
  }
}
