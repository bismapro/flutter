import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Login failed';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmationPassword,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmationPassword,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Register failed';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> refresh() async {
    try {
      final response = await ApiClient.dio.post('/refresh');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Refresh token failed';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('/me');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Get current user failed';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }

  static Future<bool> logout() async {
    try {
      final response = await ApiClient.dio.post('/logout');

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Logout failed';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }
}
