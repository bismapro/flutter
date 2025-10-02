import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    logger.fine('=== ProfileService.getProfile() called ===');
    try {
      logger.fine('Making API call to /auth/me...');
      final response = await ApiClient.dio.post('/auth/me');

      logger.fine('API Response Status: ${response.statusCode}');
      logger.fine('API Response Data: ${response.data}');
      logger.fine('API Response Type: ${response.data.runtimeType}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.fine('DioException caught:');
      logger.fine('Status Code: ${e.response?.statusCode}');
      logger.fine('Response Data: ${e.response?.data}');
      logger.fine('Error Message: ${e.message}');

      String errorMessage = 'Failed to get profile';
      ApiClient.parseDioError(e, errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      logger.fine('General Exception caught: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await ApiClient.dio.put(
        '/profile',
        data: {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to update profile';

      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;

        if (data.containsKey('errors') && data['errors'] != null) {
          final errors = data['errors'];

          if (errors is Map) {
            List<String> errorMessages = [];
            errors.forEach((field, value) {
              if (value is List) {
                errorMessages.add('$field: ${value.join(", ")}');
              } else {
                errorMessages.add('$field: $value');
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          } else if (errors is String) {
            errorMessage = errors;
          }
        } else if (data.containsKey('message') && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }

      throw Exception(errorMessage);
    }
  }
}
