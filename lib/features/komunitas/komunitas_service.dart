import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

class KomunitasService {
  static Future<Map<String, dynamic>> getAllArtikel({int page = 1}) async {
    try {
      final response = await ApiClient.dio.get(
        '/komunitas/artikel',
        queryParameters: {'page': page},
      );
      logger.fine('Get all artikel response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch latest articles';

      final error = ApiClient.parseDioError(e, errorMessage);

      throw Exception(error);
    }
  }
}
