import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/progres_puasa/progres_puasa.dart';

class PuasaService {
  // Add Progres Puasa Wajib
  static Future<Map<String, dynamic>> addProgresPuasaWajib({
    required String tanggalRamadhan,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/puasa/wajib',
        data: {'tanggal_ramadhan': tanggalRamadhan},
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> deleteProgresPuasaWajib({
    required String id,
  }) async {
    try {
      final response = await ApiClient.dio.delete('/puasa/wajib/$id');

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Puasa Wajib Tahun Ini
  static Future<Map<String, dynamic>> getProgresPuasaWajibTahunIni() async {
    try {
      final response = await ApiClient.dio.get('/puasa/wajib/tahun-ini');

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Puasa Wajib Riwayat
  static Future<Map<String, dynamic>> getRiwayatPuasaWajib() async {
    try {
      final response = await ApiClient.dio.get('/puasa/wajib/riwayat');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as List<dynamic>? ?? [];
      final riwayat = data
          .map((e) => RiwayatPuasaWajib.fromJson(e as Map<String, dynamic>))
          .toList();
      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': riwayat,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
