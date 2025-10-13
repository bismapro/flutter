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

  static String parseDioError(
    DioException e, {
    String fallback = 'Terjadi kesalahan! Silakan coba lagi.',
  }) {
    logger.fine('Dio error occurred: $e');
    // 1. Prioritaskan pesan error dari Dio jika ada (misal: timeout, no internet)
    if (e.message != null && e.response == null) {
      // Cek pesan umum seperti koneksi timeout atau masalah jaringan
      if (e.message!.contains('SocketException') ||
          e.message!.contains('Connecting timed out')) {
        return 'Koneksi internet bermasalah. Silakan coba lagi.';
      }
      return e.message!;
    }

    // 2. Jika ada respons dari server, coba parse datanya
    if (e.response?.data != null) {
      final data = e.response!.data;
      logger.fine('Parsing Dio error response: $data');

      // Jika respons data adalah Map (JSON Object)
      if (data is Map<String, dynamic>) {
        // Cek kunci 'message' (paling umum)
        if (data.containsKey('message') && data['message'] is String) {
          return data['message'];
        }

        // Cek kunci 'errors' (umum untuk error validasi)
        if (data.containsKey('errors') && data['errors'] != null) {
          final errors = data['errors'];
          // Jika 'errors' adalah String
          if (errors is String) {
            return errors;
          }
          // Jika 'errors' adalah Map berisi list pesan
          if (errors is Map) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first
                  .toString(); // Ambil pesan error pertama dari list
            }
            return firstError.toString();
          }
        }
      }
      // Jika respons data hanyalah sebuah String
      else if (data is String) {
        return data;
      }
    }

    // 3. Jika semua gagal, gunakan fallback message
    return fallback;
  }
}
