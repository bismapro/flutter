import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/komunitas/kategori_komunitas.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';

class KomunitasService {
  // Get All Kategori Postingan
  static Future<Map<String, dynamic>> getAllKategoriPostingan() async {
    try {
      final response = await ApiClient.dio.get('/komunitas/kategori');

      final responseData = response.data as Map<String, dynamic>;

      final kategoriPostingan = responseData['data'] as List<dynamic>? ?? [];
      final kategoriList = kategoriPostingan
          .map((e) => KategoriKomunitas.fromJson(e as Map<String, dynamic>))
          .toList();

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': kategoriList,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get All Postingan
  static Future<Map<String, dynamic>> getAllPostingan({
    int page = 1,
    keyword = '',
    kategoriId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/komunitas/postingan',
        queryParameters: {
          'page': page,
          'keyword': keyword,
          if (kategoriId != null) 'kategori_id': kategoriId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final postinganData = responseData['data'] as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': postinganData,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Get Detail Postingan
  static Future<Map<String, dynamic>> getPostinganById(String id) async {
    try {
      final response = await ApiClient.dio.get('/komunitas/postingan/$id');

      final responseData = response.data as Map<String, dynamic>;
      final postingan = responseData['data'] as Map<String, dynamic>;

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': postingan,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Create Postingan
  static Future<Map<String, dynamic>> createPostingan({
    required String kategoriId,
    required String judul,
    required XFile cover,
    required String konten,
    List<XFile>? daftarGambar,
    bool? isAnonymous,
  }) async {
    try {
      // Daftar Gambar
      List<MultipartFile> multipartImages = await Future.wait(
        daftarGambar?.map(
              (img) async =>
                  await MultipartFile.fromFile(img.path, filename: img.name),
            ) ??
            [],
      );

      // Cover Image
      MultipartFile coverImage = await MultipartFile.fromFile(
        cover.path,
        filename: cover.name,
      );

      // 🔹 Kirim sebagai FormData
      FormData formData = FormData.fromMap({
        'kategori_id': kategoriId,
        'judul': judul,
        'cover': coverImage,
        'konten': konten,
        'daftar_gambar[]': multipartImages,
        if (isAnonymous != null) 'is_anonymous': isAnonymous,
      });

      final response = await ApiClient.dio.post(
        '/komunitas/postingan',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final postingan = KomunitasPostingan.fromJson(responseData['data']);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': postingan,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Delete Postingan
  static Future<Map<String, dynamic>> deletePostingan(String id) async {
    try {
      final response = await ApiClient.dio.delete('/komunitas/postingan/$id');

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

  // Tambah Komentar
  static Future<Map<String, dynamic>> addComment({
    required String postinganId,
    required String komentar,
    bool? isAnonymous,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/komunitas/postingan/$postinganId/komentar',
        data: {'komentar': komentar, 'is_anonymous': isAnonymous},
      );

      final responseData = response.data as Map<String, dynamic>;
      final komentarData = Komentar.fromJson(responseData['data']);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'data': komentarData,
      };
    } on DioException catch (e) {
      final error = ApiClient.parseDioError(e);
      throw Exception(error);
    }
  }

  // Toggle Like
  static Future<Map<String, dynamic>> toggleLike(String postinganId) async {
    try {
      final response = await ApiClient.dio.post(
        '/komunitas/postingan/$postinganId/like',
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

  // Report Postingan
  static Future<Map<String, dynamic>> reportPostingan({
    required String postinganId,
    required String alasan,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/komunitas/postingan/$postinganId/report',
        data: {'alasan': alasan},
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
}
