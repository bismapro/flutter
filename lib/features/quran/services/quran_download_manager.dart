import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:test_flutter/features/quran/services/quran_api_service.dart';

class QuranDownloadManager {
  static final Map<String, StreamController<double>> _downloadProgress = {};

  // Get download progress stream for specific surah
  static Stream<double> getDownloadProgress(String key) {
    if (!_downloadProgress.containsKey(key)) {
      _downloadProgress[key] = StreamController<double>.broadcast();
    }
    return _downloadProgress[key]!.stream;
  }

  // Check if surah is downloaded
  static Future<bool> isDownloaded(int surahNumber, int qoriId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'downloaded_${surahNumber}_$qoriId';
    final isDownloaded = prefs.getBool(key) ?? false;

    // Verify file actually exists
    if (isDownloaded) {
      final localPath = await getLocalPath(surahNumber, qoriId);
      final file = File(localPath);
      if (!await file.exists()) {
        // File doesn't exist, remove the flag
        await prefs.remove(key);
        return false;
      }
    }

    return isDownloaded;
  }

  // Get local file path
  static Future<String> getLocalPath(int surahNumber, int qoriId) async {
    final directory = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${directory.path}/quran_audio/qori_$qoriId');

    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }

    return '${surahDir.path}/surah_$surahNumber.mp3';
  }

  // Get qori name from ID
  static Future<String?> getQoriName(int qoriId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('qori_name_$qoriId');
  }

  // Save qori name
  static Future<void> saveQoriName(int qoriId, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qori_name_$qoriId', name);
  }

  // Download surah audio from backend
  static Future<DownloadResult> downloadSurah(
    int surahNumber,
    int qoriId,
  ) async {
    final key = 'progress_${surahNumber}_$qoriId';

    try {
      print('📥 Starting download for Surah $surahNumber, Qori ID $qoriId');

      // Initialize progress controller
      if (!_downloadProgress.containsKey(key)) {
        _downloadProgress[key] = StreamController<double>.broadcast();
      }

      // Get audio URL from backend
      print('🔄 Fetching audio URL from backend...');
      final audioResponse = await QuranApiService.getAudioUrl(
        qoriId,
        surahNumber,
      );

      print('✅ Got audio URL: ${audioResponse.audioFull}');

      // Save qori name
      await saveQoriName(qoriId, audioResponse.qori.name);
      print('💾 Saved qori name: ${audioResponse.qori.name}');

      final localPath = await getLocalPath(surahNumber, qoriId);
      print('📂 Local save path: $localPath');

      // Download audio file
      print('⬇️ Starting file download...');
      await QuranApiService.downloadAudio(audioResponse.audioFull, localPath, (
        received,
        total,
      ) {
        if (total != -1) {
          final progress = received / total;
          _downloadProgress[key]?.add(progress);
        }
      });

      // Mark as downloaded
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('downloaded_${surahNumber}_$qoriId', true);
      await prefs.setString(
        'downloaded_url_${surahNumber}_$qoriId',
        audioResponse.audioFull,
      );

      _downloadProgress[key]?.add(1.0);
      print('✅ Download completed successfully');

      return DownloadResult(
        success: true,
        message: 'Download completed successfully',
      );
    } catch (e) {
      print('❌ Download error: $e');
      _downloadProgress[key]?.add(0.0);

      String errorMessage = 'Download failed';

      if (e.toString().contains('404')) {
        errorMessage =
            'Audio not available for this Surah and Qori combination';
      } else if (e.toString().contains('Failed to get audio URL')) {
        errorMessage = 'Failed to get audio URL from server';
      } else if (e.toString().contains('Failed to download audio')) {
        errorMessage = 'Failed to download audio file';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else {
        errorMessage = e.toString();
      }

      return DownloadResult(
        success: false,
        message: errorMessage,
        error: e.toString(),
      );
    }
  }

  // Delete downloaded surah
  static Future<bool> deleteSurah(int surahNumber, int qoriId) async {
    try {
      print('🗑️ Deleting Surah $surahNumber, Qori ID $qoriId');

      final localPath = await getLocalPath(surahNumber, qoriId);
      final file = File(localPath);

      if (await file.exists()) {
        await file.delete();
        print('✅ File deleted: $localPath');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('downloaded_${surahNumber}_$qoriId');
      await prefs.remove('downloaded_url_${surahNumber}_$qoriId');

      print('✅ Download markers removed');
      return true;
    } catch (e) {
      print('❌ Delete error: $e');
      return false;
    }
  }

  // Get all downloaded surahs for a qori
  static Future<List<int>> getDownloadedSurahs(int qoriId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final List<int> downloadedSurahs = [];

    for (final key in keys) {
      if (key.startsWith('downloaded_') && key.endsWith('_$qoriId')) {
        final isDownloaded = prefs.getBool(key) ?? false;
        if (isDownloaded) {
          final surahNumber = int.tryParse(
            key.replaceAll('downloaded_', '').replaceAll('_$qoriId', ''),
          );
          if (surahNumber != null) {
            downloadedSurahs.add(surahNumber);
          }
        }
      }
    }

    return downloadedSurahs;
  }

  // Get file size
  static Future<String> getFileSize(int surahNumber, int qoriId) async {
    try {
      final localPath = await getLocalPath(surahNumber, qoriId);
      final file = File(localPath);

      if (await file.exists()) {
        final bytes = await file.length();
        return _formatBytes(bytes);
      }
      return '0 MB';
    } catch (e) {
      return '0 MB';
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static void dispose() {
    for (var controller in _downloadProgress.values) {
      controller.close();
    }
    _downloadProgress.clear();
  }
}

// Download result model
class DownloadResult {
  final bool success;
  final String message;
  final String? error;

  DownloadResult({required this.success, required this.message, this.error});
}
