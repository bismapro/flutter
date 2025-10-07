import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

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

      logger.fine('Update Profile Response Data: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.warning('DioException: ${e.message}');
      String errorMessage = 'Failed to update profile';

      ApiClient.parseDioError(e, errorMessage);

      throw Exception(errorMessage);
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

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to update password';

      ApiClient.parseDioError(e, errorMessage);

      throw Exception(errorMessage);
    }
  }
}
