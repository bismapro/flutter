import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sheikh.dart';
import '../models/surah.dart';

class AudioDownloadService {
  static const List<Sheikh> availableSheikhs = [
    Sheikh(
      id: 'abdul_basit',
      name: 'Abdul Basit',
      arabicName: 'عبد الباسط عبد الصمد',
      country: 'مصر',
      avatar: '🎙️',
      isPopular: true,
    ),
    Sheikh(
      id: 'mishary_rashid',
      name: 'Mishary Rashid',
      arabicName: 'مشاري راشد العفاسي',
      country: 'الكويت',
      avatar: '🎤',
      isPopular: true,
    ),
    Sheikh(
      id: 'maher_muaiqly',
      name: 'Maher Al Muaiqly',
      arabicName: 'ماهر المعيقلي',
      country: 'السعودية',
      avatar: '🕌',
      isPopular: true,
    ),
    Sheikh(
      id: 'ahmed_ajamy',
      name: 'Ahmed Al Ajamy',
      arabicName: 'أحمد العجمي',
      country: 'السعودية',
      avatar: '📿',
    ),
    Sheikh(
      id: 'saad_ghamdi',
      name: 'Saad Al Ghamdi',
      arabicName: 'سعد الغامدي',
      country: 'السعودية',
      avatar: '🌙',
    ),
    Sheikh(
      id: 'sudais',
      name: 'Abdul Rahman Sudais',
      arabicName: 'عبد الرحمن السديس',
      country: 'السعودية',
      avatar: '🕋',
      isPopular: true,
    ),
  ];

  static List<Sheikh> getAllSheikhs() {
    return availableSheikhs;
  }

  static List<Sheikh> getPopularSheikhs() {
    return availableSheikhs.where((sheikh) => sheikh.isPopular).toList();
  }

  static Future<String> getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/quran_audio');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  static Future<bool> isAudioDownloaded(String surahId, String sheikhId) async {
    try {
      final downloadPath = await getDownloadPath();
      final fileName = 'surah_${surahId}_${sheikhId}.mp3';
      final file = File('$downloadPath/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<int> getDownloadedFileSize(
    String surahId,
    String sheikhId,
  ) async {
    try {
      final downloadPath = await getDownloadPath();
      final fileName = 'surah_${surahId}_${sheikhId}.mp3';
      final file = File('$downloadPath/$fileName');
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // Ignore
    }
    return 0;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  static Stream<AudioDownload> downloadAudio({
    required Surah surah,
    required Sheikh sheikh,
    Function(String)? onError,
  }) async* {
    try {
      final downloadPath = await getDownloadPath();
      final fileName = 'surah_${surah.nomor}_${sheikh.id}.mp3';
      final filePath = '$downloadPath/$fileName';

      // Generate mock URL (in real app, you would get this from API)
      final audioUrl = _generateAudioUrl(surah.nomor, sheikh.id);

      yield AudioDownload(
        surahId: surah.nomor.toString(),
        sheikhId: sheikh.id,
        fileName: fileName,
        filePath: filePath,
        fileSize: 0,
        downloadDate: DateTime.now(),
        progress: 0.0,
        status: DownloadStatus.downloading,
      );

      // Simulate download with progress updates
      // In real app, you would use actual HTTP download
      await _simulateDownload(audioUrl, filePath, (progress, fileSize) async* {
        yield AudioDownload(
          surahId: surah.nomor.toString(),
          sheikhId: sheikh.id,
          fileName: fileName,
          filePath: filePath,
          fileSize: fileSize,
          downloadDate: DateTime.now(),
          progress: progress,
          status: DownloadStatus.downloading,
        );
      });

      // Create actual file with some content
      final file = File(filePath);
      await file.writeAsBytes(
        Uint8List.fromList(List.filled(1024 * 512, 0)),
      ); // 512KB dummy file

      final finalFileSize = await file.length();

      yield AudioDownload(
        surahId: surah.nomor.toString(),
        sheikhId: sheikh.id,
        fileName: fileName,
        filePath: filePath,
        fileSize: finalFileSize,
        downloadDate: DateTime.now(),
        progress: 1.0,
        status: DownloadStatus.completed,
      );
    } catch (e) {
      onError?.call(e.toString());
      yield AudioDownload(
        surahId: surah.nomor.toString(),
        sheikhId: sheikh.id,
        fileName: 'surah_${surah.nomor}_${sheikh.id}.mp3',
        filePath: '',
        fileSize: 0,
        downloadDate: DateTime.now(),
        progress: 0.0,
        status: DownloadStatus.failed,
      );
    }
  }

  static String _generateAudioUrl(int surahNumber, String sheikhId) {
    // Mock URL generation - in real app this would come from your API
    return 'https://download.quranicaudio.com/quran/${sheikhId}/${surahNumber.toString().padLeft(3, '0')}.mp3';
  }

  static Stream<void> _simulateDownload(
    String url,
    String filePath,
    Stream<AudioDownload> Function(double progress, int fileSize) onProgress,
  ) async* {
    // Simulate download progress
    final random = DateTime.now().millisecondsSinceEpoch;
    final fileSize =
        300000 + (random % 500000); // Random size between 300KB - 800KB

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      final progress = i / 100.0;
      yield* onProgress(progress, fileSize);
    }
  }

  static Future<void> deleteAudio(String surahId, String sheikhId) async {
    try {
      final downloadPath = await getDownloadPath();
      final fileName = 'surah_${surahId}_${sheikhId}.mp3';
      final file = File('$downloadPath/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error
    }
  }

  static Future<List<AudioDownload>> getDownloadedAudios() async {
    try {
      final downloadPath = await getDownloadPath();
      final directory = Directory(downloadPath);
      final files = await directory.list().toList();

      List<AudioDownload> downloads = [];
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final fileName = file.path.split('/').last;
          final parts = fileName.replaceAll('.mp3', '').split('_');
          if (parts.length >= 3) {
            final surahId = parts[1];
            final sheikhId = parts[2];
            final fileSize = await file.length();

            downloads.add(
              AudioDownload(
                surahId: surahId,
                sheikhId: sheikhId,
                fileName: fileName,
                filePath: file.path,
                fileSize: fileSize,
                downloadDate: await file.lastModified(),
                progress: 1.0,
                status: DownloadStatus.completed,
              ),
            );
          }
        }
      }
      return downloads;
    } catch (e) {
      return [];
    }
  }
}
