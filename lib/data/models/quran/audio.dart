import 'package:test_flutter/data/models/quran/qori.dart';

class AudioResponse {
  final bool status;
  final String message;
  final Qori qori;
  final int surat;
  final String audioFull;

  AudioResponse({
    required this.status,
    required this.message,
    required this.qori,
    required this.surat,
    required this.audioFull,
  });

  factory AudioResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return AudioResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      qori: Qori.fromJson(data?['qori'] ?? {}),
      surat: data?['surat'] ?? 0,
      audioFull: data?['audio_full'] ?? '',
    );
  }
}
