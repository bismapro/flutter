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

  // Delete Progres Puasa Wajib
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

  // Add Progres Puasa Sunnah
  static Future<Map<String, dynamic>> addProgresPuasaSunnah({
    required String jenis,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/puasa/sunnah',
        data: {'jenis': jenis},
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Delete Progres Puasa Sunnah
  static Future<Map<String, dynamic>> deleteProgresPuasaSunnah({
    required String id,
  }) async {
    try {
      final response = await ApiClient.dio.delete('/puasa/sunnah/$id');

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

  // Get Progress Puasa Sunnah Tahun Ini
  static Future<Map<String, dynamic>> getProgresPuasaSunnahTahunIni({
    required String jenis,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/puasa/sunnah/tahun-ini',
        queryParameters: {'jenis': jenis},
      );

      final responseData = response.data as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': responseData['data'] as Map<String, dynamic>,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Progress Puasa Sunnah Riwayat
  static Future<Map<String, dynamic>> getRiwayatPuasaSunnah({
    required String jenis,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/puasa/sunnah/riwayat',
        queryParameters: {'jenis': jenis},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': data,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
