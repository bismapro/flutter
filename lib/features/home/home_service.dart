import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas.dart';
import 'package:test_flutter/data/models/sholat.dart';

class HomeService {
  static Future<Map<String, dynamic>> getLatestArticle() async {
    try {
      final response = await ApiClient.dio.get('/komunitas/artikel/terbaru');
      logger.fine('Get latest article response', response.data);

      final responseData = response.data as Map<String, dynamic>;
      final articlesData = responseData['data'] as List;

      // Convert to KomunitasArtikel objects
      final articles = articlesData
          .map((json) => KomunitasArtikel.fromJson(json))
          .toList();

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': articles,
      };
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch latest article';
      final error = ApiClient.parseDioError(e, errorMessage);
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

      logger.fine('Get jadwal sholat response', response.data);

      final responseData = response.data as Map<String, dynamic>;
      final sholat = Sholat.fromJson(responseData['data']);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': sholat,
      };
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch jadwal sholat';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }
}
