import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/data/models/quran/audio.dart';
import 'package:test_flutter/data/models/quran/qori.dart';

class QuranApiService {
  // Get list of available qori
  static Future<List<Qori>> getQoriList() async {
    try {
      print('🔄 Fetching qori list from: /quran/surat/qori');
      final response = await ApiClient.dio.get('/quran/surat/qori');

      print('✅ Qori list response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final qoriResponse = QoriListResponse.fromJson(response.data);
        print('✅ Successfully parsed ${qoriResponse.qoriList.length} qori');
        return qoriResponse.qoriList;
      } else {
        throw Exception(
          'Failed to load qori list: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in getQoriList:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw Exception('Failed to load qori list: ${e.message}');
    } catch (e) {
      print('❌ Error fetching qori list: $e');
      throw Exception('Failed to load qori list: $e');
    }
  }

  // Get audio URL for specific surah and qori
  static Future<AudioResponse> getAudioUrl(int qoriId, int suratNumber) async {
    try {
      final endpoint = '/quran/surat/audio';
      final params = {'qori_id': qoriId, 'surat': suratNumber};

      print('🔄 Fetching audio URL:');
      print('   Endpoint: $endpoint');
      print('   Query params: $params');

      final response = await ApiClient.dio.get(
        endpoint,
        queryParameters: params,
      );

      print('✅ Audio URL response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final audioResponse = AudioResponse.fromJson(response.data);
        print('✅ Successfully got audio URL: ${audioResponse.audioFull}');
        return audioResponse;
      } else {
        throw Exception(
          'Failed to get audio URL: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in getAudioUrl:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Request URL: ${e.requestOptions.uri}');

      if (e.response?.statusCode == 404) {
        throw Exception(
          'Audio not found for qori_id: $qoriId, surat: $suratNumber. '
          'Please check if this combination exists on the server.',
        );
      }

      throw Exception('Failed to get audio URL: ${e.message}');
    } catch (e) {
      print('❌ Error fetching audio URL: $e');
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
      print('🔄 Starting download:');
      print('   URL: $audioUrl');
      print('   Save path: $savePath');

      await ApiClient.dio.download(
        audioUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('📥 Download progress: $progress% ($received/$total bytes)');
          }
          onProgress?.call(received, total);
        },
      );

      print('✅ Download completed successfully');
    } on DioException catch (e) {
      print('❌ DioException in downloadAudio:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw Exception('Failed to download audio: ${e.message}');
    } catch (e) {
      print('❌ Error downloading audio: $e');
      throw Exception('Failed to download audio: $e');
    }
  }
}
