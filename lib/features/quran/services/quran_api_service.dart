import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/quran/audio.dart';
import 'package:test_flutter/data/models/quran/qori.dart';

class QuranApiService {
  // Get list of available qori
  static Future<List<Qori>> getQoriList() async {
    try {
      final response = await ApiClient.dio.get('/quran/surat/qori');

      if (response.statusCode == 200) {
        final qoriResponse = QoriListResponse.fromJson(response.data);
        return qoriResponse.qoriList;
      } else {
        throw Exception(
          'Failed to load qori list: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to load qori list: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load qori list: $e');
    }
  }

  // Get audio URL for specific surah and qori
  static Future<AudioResponse> getAudioUrl(int qoriId, int suratNumber) async {
    try {
      final endpoint = '/quran/surat/audio';
      final params = {'qori_id': qoriId, 'surat': suratNumber};

      final response = await ApiClient.dio.get(
        endpoint,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final audioResponse = AudioResponse.fromJson(response.data);
        return audioResponse;
      } else {
        throw Exception(
          'Failed to get audio URL: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'Audio not found for qori_id: $qoriId, surat: $suratNumber. '
          'Please check if this combination exists on the server.',
        );
      }

      throw Exception('Failed to get audio URL: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get audio URL: $e');
    }
  }

  // Download audio file with progress
  static Future<void> downloadAudio(
    String audioUrl,
    String savePath,
    Function(int received, int total)? onProgress,
  ) async {
    try {
      await ApiClient.dio.download(
        audioUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
          }
          onProgress?.call(received, total);
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to download audio: ${e.message}');
    } catch (e) {
      throw Exception('Failed to download audio: $e');
    }
  }
}
