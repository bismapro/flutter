import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

class SholatService {
  // Get Jadwal Sholat
  static Future<Map<String, dynamic>> getJadwalSholat({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 90));
      final endDate = now.add(const Duration(days: 90));

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

  // Add Progress Sholat
  static Future<Map<String, dynamic>> addProgressSholat({
    required String jenis,
    required String sholat,
    required bool isOnTime,
    required bool isJamaah,
    required String lokasi,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/sholat/progres',
        data: {
          'jenis': jenis,
          'sholat': sholat,
          'is_on_time': isOnTime,
          'is_jamaah': isJamaah,
          'lokasi': lokasi,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Delete Progress Sholat
  static Future<Map<String, dynamic>> deleteProgressSholat({
    required int id,
  }) async {
    try {
      final response = await ApiClient.dio.delete('/sholat/progres/$id');

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Sholat Wajib Hari Ini
  static Future<Map<String, dynamic>> getProgressSholatWajibHariIni() async {
    try {
      final response = await ApiClient.dio.get(
        '/sholat/progres/wajib/hari-ini',
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Sholat Sunnah Hari Ini
  static Future<Map<String, dynamic>> getProgressSholatSunnahHariIni() async {
    try {
      final response = await ApiClient.dio.get(
        '/sholat/progres/sunnah/hari-ini',
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Wajib Riwayat
  static Future<Map<String, dynamic>> getProgressSholatWajibRiwayat() async {
    try {
      final response = await ApiClient.dio.get('/sholat/progres/wajib/riwayat');

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Sunnah Riwayat
  static Future<Map<String, dynamic>> getProgressSholatSunnahRiwayat() async {
    try {
      final response = await ApiClient.dio.get(
        '/sholat/progres/sunnah/riwayat',
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>? ?? {},
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
