import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;
      final authResponse = responseData['data'] as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': authResponse,
      };
    } on DioException catch (e) {
      logger.fine('Dio error occurred: $e');
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Register
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

      final responseData = response.data as Map<String, dynamic>;
      final authResponse = responseData['data'] as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': {
          'token': authResponse['token'] ?? '',
          'user': {
            'id': authResponse['user']['id'],
            'name': authResponse['user']['name'],
            'email': authResponse['user']['email'],
          },
        },
      };
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;

        throw Exception(
          data['errors'] ??
              data['message'] ??
              'Terjadi kesalahan ketika melakukan registrasi.',
        );
      } else {
        throw Exception('Terjadi kesalahan ketika melakukan registrasi.');
      }
    }
  }

  // Refresh Token
  static Future<Map<String, dynamic>> refresh() async {
    try {
      final response = await ApiClient.dio.post('/refresh');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Current User
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await ApiClient.dio.get('/me');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<bool> logout() async {
    try {
      final response = await ApiClient.dio.post('/logout');

      final responseData = response.data as Map<String, dynamic>;

      return responseData['status'] as bool;
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiClient.dio.post(
        '/forgot-password',
        data: {'email': email},
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;

        throw Exception(
          data['errors'] ??
              data['message'] ??
              'Terjadi kesalahan saat mengirim link reset password.',
        );
      } else {
        throw Exception('Terjadi kesalahan saat mengirim link reset password.');
      }
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;

        throw Exception(
          data['errors'] ??
              data['message'] ??
              'Terjadi kesalahan saat mereset password.',
        );
      } else {
        throw Exception('Terjadi kesalahan saat mereset password.');
      }
    }
  }
}
