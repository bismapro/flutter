import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioService {
  static AudioHandler? _audioHandler;
  static final AudioPlayer _audioPlayer = AudioPlayer();

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

  static bool get isPlaying => _audioPlayer.playing;
  static Duration get duration => _audioPlayer.duration ?? Duration.zero;
  static Duration get position => _audioPlayer.position;

  static int _totalVerses = 0;
  static int _currentVerse = 1;

  static Future<void> init() async {
    // Initialize audio handler
    _audioHandler = await AudioService.init(
      builder: () => QuranAudioHandler(_audioPlayer),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yourapp.quran.channel.audio',
        androidNotificationChannelName: 'Quran Audio',
        androidNotificationOngoing: false, // ← Changed to false
        androidStopForegroundOnPause: true, // ← Changed to true
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );

    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      _playingController.add(state.playing);
    });

    // Listen to position updates
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
      _updateCurrentVerse();
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _durationController.add(duration);
      }
    });
  }

  static void _updateCurrentVerse() {
    final duration = _audioPlayer.duration;
    final position = _audioPlayer.position;

    if (_totalVerses > 0 && duration != null && duration.inMilliseconds > 0) {
      final progress = position.inMilliseconds / duration.inMilliseconds;
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

    final mediaItem = MediaItem(
      id: url,
      title: title,
      artist: artist,
      artUri: artwork != null ? Uri.parse(artwork) : null,
    );

    // Set audio source
    await _audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(url), tag: mediaItem),
    );

    // Update media item for notification
    await _audioHandler?.updateMediaItem(
      mediaItem,
    ); // ← Fixed: use updateMediaItem

    await _audioPlayer.play();
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

    final mediaItem = MediaItem(
      id: filePath,
      title: title,
      artist: artist,
      artUri: artwork != null ? Uri.parse(artwork) : null,
    );

    // Set audio source from file
    await _audioPlayer.setAudioSource(
      AudioSource.file(filePath, tag: mediaItem),
    );

    // Update media item for notification
    await _audioHandler?.updateMediaItem(
      mediaItem,
    ); // ← Fixed: use updateMediaItem

    await _audioPlayer.play();
    _currentVerseController.add(1);
  }

  static Future<void> pause() async {
    await _audioPlayer.pause();
  }

  static Future<void> resume() async {
    await _audioPlayer.play();
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

// Audio Handler for background audio
class QuranAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  QuranAudioHandler(this._player) {
    // Initialize playback state
    playbackState.add(
      PlaybackState(
        playing: false,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        processingState: AudioProcessingState.idle,
      ),
    );

    // Propagate player events to audio handler
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processingState = {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[state.processingState]!;

      playbackState.add(
        playbackState.value.copyWith(
          playing: playing,
          processingState: processingState,
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
        ),
      );
    });

    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        mediaItem.add(mediaItem.value?.copyWith(duration: duration));
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // Implement skip to next surah if needed
  }

  @override
  Future<void> skipToPrevious() async {
    // Implement skip to previous surah if needed
  }

  Future<void> updateMediaItem(MediaItem item) async {
    mediaItem.add(item);
  }
}
