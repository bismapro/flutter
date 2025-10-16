import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class QuranAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Duration _currentDuration = Duration.zero;
  static Duration _currentPosition = Duration.zero;

  static final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  static final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  static final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  static final StreamController<int> _currentVerseController =
      StreamController<int>.broadcast();

  static Stream<bool> get playingStream => _playingController.stream;
  static Stream<Duration> get positionStream => _positionController.stream;
  static Stream<Duration> get durationStream => _durationController.stream;
  static Stream<int> get currentVerseStream => _currentVerseController.stream;

  static bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  static Duration get duration => _currentDuration;
  static Duration get position => _currentPosition;

  static int _totalVerses = 0;
  static int _currentVerse = 1;

  static void init() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playingController.add(state == PlayerState.playing);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _positionController.add(position);
      _updateCurrentVerse();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _currentDuration = duration;
      _durationController.add(duration);
    });
  }

  static void _updateCurrentVerse() {
    if (_totalVerses > 0 && _currentDuration.inMilliseconds > 0) {
      // Calculate current verse based on position
      final progress =
          _currentPosition.inMilliseconds / _currentDuration.inMilliseconds;
      final newVerse = ((progress * _totalVerses).floor() + 1).clamp(
        1,
        _totalVerses,
      );

      if (newVerse != _currentVerse) {
        _currentVerse = newVerse;
        _currentVerseController.add(_currentVerse);
      }
    }
  }

  static Future<void> playFromUrl(
    String url,
    String title,
    String artist,
    String? artwork,
    int totalVerses,
  ) async {
    _totalVerses = totalVerses;
    _currentVerse = 1;
    await _audioPlayer.play(UrlSource(url));
    _currentVerseController.add(1);
  }

  static Future<void> playFromFile(
    String filePath,
    String title,
    String artist,
    String? artwork,
    int totalVerses,
  ) async {
    _totalVerses = totalVerses;
    _currentVerse = 1;
    await _audioPlayer.play(DeviceFileSource(filePath));
    _currentVerseController.add(1);
  }

  static Future<void> pause() async {
    await _audioPlayer.pause();
  }

  static Future<void> resume() async {
    await _audioPlayer.resume();
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
    _currentVerse = 1;
    _totalVerses = 0;
    _currentVerseController.add(1);
  }

  static Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  static void dispose() {
    _audioPlayer.dispose();
    _playingController.close();
    _positionController.close();
    _durationController.close();
    _currentVerseController.close();
  }
}
