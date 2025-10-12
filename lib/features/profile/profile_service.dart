import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/reponse_format.dart';

class ProfileService {
  static Future<ResponseFormat> updateProfile(
    String name,
    String email,
    String? phone,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/edit-profile',
        data: {'name': name, 'email': email, if (phone != null) 'phone': phone},
      );

      final responseData = ResponseFormat.fromJson(
        response.data as Map<String, dynamic>,
      );

      return responseData;
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<ResponseFormat> updatePassword(
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

      final responseData = ResponseFormat.fromJson(
        response.data as Map<String, dynamic>,
      );

      return responseData;
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
