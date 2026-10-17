import 'package:dio/dio.dart';
import '../domain/models/auth_user.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthUser> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthUser.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
