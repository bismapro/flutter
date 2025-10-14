import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

class SholatService {
  static Future<Map<String, dynamic>> getJadwalSholat({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final endDate = now.add(const Duration(days: 14));

      final response = await ApiClient.dio.get(
        '/sholat/jadwal',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final kategoriPostingan = responseData['data'] as List<dynamic>? ?? [];
      final sholatList = kategoriPostingan
          .map((e) => Sholat.fromJson(e as Map<String, dynamic>))
          .toList();

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': sholatList,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
