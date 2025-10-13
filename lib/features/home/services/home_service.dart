import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

class HomeService {
  static Future<Map<String, dynamic>> getLatestArticle() async {
    try {
      final response = await ApiClient.dio.get('/komunitas/artikel/terbaru');

      logger.fine('Get latest article response: ${response.data}');

      final responseData = response.data;

      if (!responseData.status) {
        throw Exception(responseData.message ?? 'Failed to load articles');
      }

      final articlesData = responseData.data as List;
      final articles = articlesData
          .map((json) => KomunitasPostingan.fromJson(json))
          .toList();

      return {
        'status': responseData.status,
        'message': responseData.message,
        'data': articles,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> getJadwalSholat({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/sholat/jadwal',
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );

      logger.fine('Get jadwal sholat response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;

      if (!responseData['status']) {
        throw Exception(
          responseData['message'] ?? 'Failed to load prayer schedule',
        );
      }

      final sholat = Sholat.fromJson(responseData['data']);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': sholat,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
