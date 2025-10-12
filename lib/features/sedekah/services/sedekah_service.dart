import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/sedekah/sedekah.dart';

class SedekahService {
  // Fetch sedekah
  static Future<Map<String, dynamic>> loadStats() async {
    try {
      final response = await ApiClient.dio.get('/sedekah/progres/statistik');
      final responseData = response.data as Map<String, dynamic>;

      final statsData = StatistikSedekah.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': statsData,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> addSedekah({
    required String jenisSedekah,
    required String tanggal,
    required int jumlah,
    String? keterangan,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/sedekah/progres/add',
        data: {
          'jenis_sedekah': jenisSedekah,
          'tanggal': tanggal,
          'jumlah': jumlah,
          if (keterangan != null && keterangan.isNotEmpty)
            'keterangan': keterangan,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final sedekah = Sedekah.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': sedekah,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }
}
