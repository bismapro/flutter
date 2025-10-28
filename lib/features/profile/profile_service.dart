import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>> updateProfile(
    String name,
    String email,
    String? phone,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/edit-profile',
        data: {'name': name, 'email': email, if (phone != null) 'phone': phone},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': data,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/edit-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
