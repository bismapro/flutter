import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

class SholatService {
  static Future<Map<String, dynamic>> getJadwalSholat({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/sholat/jadwal',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      logger.fine('Get jadwal sholat response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
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
