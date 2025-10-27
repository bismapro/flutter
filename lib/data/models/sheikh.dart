class Sheikh {
  final String id;
  final String name;
  final String arabicName;
  final String country;
  final String avatar;
  final bool isPopular;

  const Sheikh({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.country,
    required this.avatar,
    this.isPopular = false,
  });

  factory Sheikh.fromJson(Map<String, dynamic> json) {
    return Sheikh(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabicName'] ?? '',
      country: json['country'] ?? '',
      avatar: json['avatar'] ?? '',
      isPopular: json['isPopular'] ?? false,
    );
  }
}

class AudioDownload {
  final String surahId;
  final String sheikhId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime downloadDate;
  final double progress;
  final DownloadStatus status;

  const AudioDownload({
    required this.surahId,
    required this.sheikhId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.downloadDate,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
  });

  AudioDownload copyWith({
    String? surahId,
    String? sheikhId,
    String? fileName,
    String? filePath,
    int? fileSize,
    DateTime? downloadDate,
    double? progress,
    DownloadStatus? status,
  }) {
    return AudioDownload(
      surahId: surahId ?? this.surahId,
      sheikhId: sheikhId ?? this.sheikhId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      downloadDate: downloadDate ?? this.downloadDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}

enum DownloadStatus { pending, downloading, completed, failed, paused }
