import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/services/audio_notification_service.dart';

// Simplified audio service untuk background playback dengan notification
class QuranAudioService {
  static AudioPlayer? _audioPlayer;
  static StreamController<bool>? _playingController;
  static StreamController<Duration>? _positionController;
  static StreamController<Duration>? _durationController;
  static String _currentSurah = '';
  static String _currentReciter = '';
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();
    _playingController = StreamController<bool>.broadcast();
    _positionController = StreamController<Duration>.broadcast();
    _durationController = StreamController<Duration>.broadcast();

    // Initialize notification service
    await AudioNotificationService.init();

    // Listen to player state changes
    _audioPlayer!.onPlayerStateChanged.listen((state) {
      final isPlaying = state == PlayerState.playing;
      _playingController!.add(isPlaying);

      // Update notification
      if (_currentSurah.isNotEmpty) {
        AudioNotificationService.updateNotification(
          title: _currentSurah,
          artist: _currentReciter,
          isPlaying: isPlaying,
        );
      }
    });

    // Listen to position changes
    _audioPlayer!.onPositionChanged.listen((position) {
      _positionController!.add(position);
    });

    // Listen to duration changes
    _audioPlayer!.onDurationChanged.listen((duration) {
      _durationController!.add(duration);
    });

    // Handle player completion
    _audioPlayer!.onPlayerComplete.listen((_) {
      AudioNotificationService.hideAudioNotification();
    });

    _isInitialized = true;
  }

  static Future<void> playFromUrl(
    String url,
    String surahName,
    String reciterName,
    String arabicName,
  ) async {
    await init();

    _currentSurah = surahName;
    _currentReciter = reciterName;

    try {
      await _audioPlayer!.play(UrlSource(url));

      // Show notification
      AudioNotificationService.showAudioNotification(
        title: surahName,
        artist: reciterName,
        isPlaying: true,
        onPlay: () => play(),
        onPause: () => pause(),
        onStop: () => stop(),
      );
    } catch (e) {
      logger.fine('Error playing audio: $e');
      throw e;
    }
  }

  static Future<void> play() async {
    await _audioPlayer?.resume();
  }

  static Future<void> pause() async {
    await _audioPlayer?.pause();
  }

  static Future<void> stop() async {
    await _audioPlayer?.stop();
    await AudioNotificationService.hideAudioNotification();
  }

  static Future<void> seek(Duration position) async {
    await _audioPlayer?.seek(position);
  }

  // Getters
  static bool get isPlaying => _audioPlayer?.state == PlayerState.playing;
  static String get currentSurah => _currentSurah;
  static String get currentReciter => _currentReciter;
  static bool get isInitialized => _isInitialized;

  // Streams
  static Stream<bool>? get playingStream => _playingController?.stream;
  static Stream<Duration>? get positionStream => _positionController?.stream;
  static Stream<Duration>? get durationStream => _durationController?.stream;

  // Direct player streams
  static Stream<PlayerState>? get playerStateStream =>
      _audioPlayer?.onPlayerStateChanged;
  static Stream<Duration>? get playerPositionStream =>
      _audioPlayer?.onPositionChanged;
  static Stream<Duration>? get playerDurationStream =>
      _audioPlayer?.onDurationChanged;

  static void dispose() {
    AudioNotificationService.hideAudioNotification();
    _audioPlayer?.dispose();
    _playingController?.close();
    _positionController?.close();
    _durationController?.close();
    _isInitialized = false;
  }
}
