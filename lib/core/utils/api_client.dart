// api_helper.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/auth_interceptor.dart';
import 'package:test_flutter/core/utils/logger.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _getFormattedBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static void setupInterceptors() {
    dio.interceptors.add(AuthInterceptor(dio));
  }

  static String _getFormattedBaseUrl() {
    String url = dotenv.env['API_URL'] ?? '';
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  static String parseDioError(DioException e, String fallback) {
    String errorMessage = fallback;

    if (e.response != null && e.response!.data is Map) {
      final data = e.response!.data as Map;

      logger.fine('Parsing Dio error response: $data');

      // Check if errors field exists first
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];

        // Process errors object that contains field-specific errors
        if (errors is Map) {
          // Convert all field errors to a formatted string
          List<String> errorMessages = [];

          errors.forEach((field, value) {
            if (value is List) {
              // For array of error messages
              errorMessages.add('$field: ${value.join(", ")}');
            } else {
              // For single error message
              errorMessages.add('$field: $value');
            }
          });

          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        } else if (errors is String) {
          errorMessage = errors;
        }
      }
      // If errors doesn't exist or is null, try message
      else if (data.containsKey('message') && data['message'] != null) {
        errorMessage = data['message'].toString();
      }
    }
    return errorMessage;
  }
}
