import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class AudioNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  static Future<void> showAudioNotification({
    required String title,
    required String artist,
    required bool isPlaying,
    required Function() onPlay,
    required Function() onPause,
    required Function() onStop,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'audio_channel',
      'Audio Playback',
      channelDescription: 'Al-Quran Audio Playback',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final playPauseText = isPlaying ? 'Pause' : 'Play';
    final body = 'Qari: $artist\n$playPauseText • Stop';

    await _notifications.show(0, title, body, notificationDetails);
  }

  static Future<void> hideAudioNotification() async {
    await _notifications.cancel(0);
  }

  static Future<void> updateNotification({
    required String title,
    required String artist,
    required bool isPlaying,
  }) async {
    await showAudioNotification(
      title: title,
      artist: artist,
      isPlaying: isPlaying,
      onPlay: () {},
      onPause: () {},
      onStop: () {},
    );
  }
}
