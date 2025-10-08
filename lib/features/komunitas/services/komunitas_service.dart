import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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

  static Future<Map<String, dynamic>> getArtikelById(String id) async {
    try {
      final response = await ApiClient.dio.get('/komunitas/artikel/$id');
      logger.fine('Get artikel by id response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch article detail';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> createArtikel({
    required String kategori,
    required String judul,
    required String isi,
    required List<XFile> gambar,
  }) async {
    try {
      // 🔹 Convert gambar ke MultipartFile
      List<MultipartFile> multipartImages = await Future.wait(
        gambar.map(
          (img) async =>
              await MultipartFile.fromFile(img.path, filename: img.name),
        ),
      );

      // 🔹 Kirim sebagai FormData
      FormData formData = FormData.fromMap({
        'kategori': kategori,
        'judul': judul,
        'isi': isi,
        'gambar[]': multipartImages, // penting: array pakai 'gambar[]'
      });

      final response = await ApiClient.dio.post(
        '/komunitas/artikel/create',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      logger.fine('Create artikel response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to create article';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> addComment({
    required String artikelId,
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/komunitas/artikel/$artikelId/komentar',
        data: {'content': content, 'is_anonymous': isAnonymous},
      );
      logger.fine('Add comment response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to add comment';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> toggleLike(String artikelId) async {
    try {
      final response = await ApiClient.dio.post(
        '/komunitas/artikel/$artikelId/like',
      );
      logger.fine('Toggle like response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to toggle like';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> getComments({
    required String artikelId,
    int page = 1,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/komunitas/artikel/$artikelId/komentar',
        queryParameters: {'page': page},
      );
      logger.fine('Get comments response', response.data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch comments';
      final error = ApiClient.parseDioError(e, errorMessage);
      throw Exception(error);
    }
  }
}
