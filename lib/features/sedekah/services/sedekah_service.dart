import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

class SedekahService {
  static Future<Map<String, dynamic>> loadStats() async {
    try {
      final response = await ApiClient.dio.get('/sedekah/progres/statistik');
      logger.fine('Get all sedekah stats response', response);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch sedekah stats';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> addSedekah(
    String jenisSedekah,
    String tanggal,
    int jumlah,
    String? keterangan,
  ) async {
    try {
      logger.fine({
        'jenis_sedekah': jenisSedekah,
        'tanggal': tanggal,
        'jumlah': jumlah,
        if (keterangan != null) 'keterangan': keterangan,
      });
      final response = await ApiClient.dio.post(
        '/sedekah/progres/add',
        data: {
          'jenis_sedekah': jenisSedekah,
          'tanggal': tanggal,
          'jumlah': jumlah,
          if (keterangan != null) 'keterangan': keterangan,
        },
      );
      logger.fine('Add sedekah response', response.data.toString());
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to add sedekah';
      ApiClient.parseDioError(e, errorMessage);
      throw Exception(errorMessage);
    }
  }
}
