import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AudioPlayer audioPlayer;
  Timer? _checkTimer;
  bool _isInitialized = false;

  // Map untuk menyimpan waktu sholat
  Map<String, String> _prayerTimes = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // Initialize notification plugin
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      audioPlayer = AudioPlayer();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              if (response.payload != null) {
                await _playAdzan();
              }
            },
      );

      await _requestPermissions();
      _startPrayerTimeChecker();
      _isInitialized = true;

      logger.fine('AlarmService initialized successfully');
    } catch (e) {
      logger.fine('Error initializing AlarmService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Set alarm untuk sholat tertentu
  Future<void> setAlarm(String prayerName, bool enabled, String time) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final key = _getAlarmKey(prayerName);

      await prefs.setBool(key, enabled);

      // Simpan waktu sholat
      _prayerTimes[prayerName] = time;
      await prefs.setString('time_$prayerName', time);

      if (enabled) {
        await _scheduleNotification(prayerName, time);
        logger.fine('Alarm enabled for $prayerName at $time');
      } else {
        await _cancelNotification(prayerName);
        logger.fine('Alarm disabled for $prayerName');
      }
    } catch (e) {
      logger.fine('Error setting alarm for $prayerName: $e');
      rethrow;
    }
  }

  /// Cek apakah alarm aktif
  Future<bool> isAlarmEnabled(String prayerName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final key = _getAlarmKey(prayerName);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      logger.fine('Error checking alarm status for $prayerName: $e');
      return false;
    }
  }

  /// Get semua status alarm
  Future<Map<String, bool>> getAllAlarmStates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, bool> alarmStates = {};

      final prayerNames = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

      for (String prayerName in prayerNames) {
        final key = _getAlarmKey(prayerName);
        alarmStates[prayerName] = prefs.getBool(key) ?? false;
      }

      return alarmStates;
    } catch (e) {
      logger.fine('Error getting alarm states: $e');
      return {};
    }
  }

  /// Update waktu sholat
  Future<void> updatePrayerTimes(Map<String, String> times) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      for (var entry in times.entries) {
        _prayerTimes[entry.key] = entry.value;
        await prefs.setString('time_${entry.key}', entry.value);

        // Jika alarm aktif, reschedule
        bool isEnabled = await isAlarmEnabled(entry.key);
        if (isEnabled) {
          await _cancelNotification(entry.key);
          await _scheduleNotification(entry.key, entry.value);
        }
      }

      logger.fine('Prayer times updated: $times');
    } catch (e) {
      logger.fine('Error updating prayer times: $e');
    }
  }

  /// Schedule notification untuk sholat
  Future<void> _scheduleNotification(String prayerName, String time) async {
    try {
      final DateTime now = DateTime.now();
      final List<String> timeParts = time.split(':');

      if (timeParts.length != 2) {
        logger.fine('Invalid time format for $prayerName: $time');
        return;
      }

      final int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has passed for today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_alarm_channel',
            'Alarm Sholat',
            channelDescription: 'Notifikasi pengingat waktu sholat',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: false,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: null,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = _getNotificationId(prayerName);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '🕌 Waktu Sholat $prayerName',
        'Saatnya melaksanakan sholat $prayerName. Allahu Akbar!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerName,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      logger.fine('Notification scheduled for $prayerName at $time');
    } catch (e) {
      logger.fine('Error scheduling notification for $prayerName: $e');
    }
  }

  /// Cancel notification
  Future<void> _cancelNotification(String prayerName) async {
    try {
      final id = _getNotificationId(prayerName);
      await flutterLocalNotificationsPlugin.cancel(id);
      logger.fine('Notification cancelled for $prayerName');
    } catch (e) {
      logger.fine('Error cancelling notification for $prayerName: $e');
    }
  }

  /// Start checker untuk mengecek waktu sholat setiap menit
  void _startPrayerTimeChecker() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkPrayerTimes();
    });
  }

  /// Check apakah sudah waktu sholat
  Future<void> _checkPrayerTimes() async {
    try {
      final DateTime now = DateTime.now();
      final String currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      SharedPreferences prefs = await SharedPreferences.getInstance();

      for (String prayerName in _prayerTimes.keys) {
        final savedTime =
            prefs.getString('time_$prayerName') ?? _prayerTimes[prayerName];

        if (savedTime == currentTime) {
          bool isEnabled = await isAlarmEnabled(prayerName);
          if (isEnabled) {
            await _playAdzan();
            await _showImmediateNotification(prayerName);
          }
        }
      }
    } catch (e) {
      logger.fine('Error checking prayer times: $e');
    }
  }

  /// Show notification immediately
  Future<void> _showImmediateNotification(String prayerName) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'prayer_now_channel',
            'Waktu Sholat Sekarang',
            channelDescription: 'Notifikasi waktu sholat tiba',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: false,
            fullScreenIntent: true,
            ongoing: true,
            autoCancel: false,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: null,
        presentAlert: true,
        presentBadge: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        '🕌 Waktu Sholat $prayerName Telah Tiba',
        'Mari segera melaksanakan sholat $prayerName. Allahu Akbar! 🤲',
        platformDetails,
        payload: prayerName,
      );

      logger.fine('Immediate notification shown for $prayerName');
    } catch (e) {
      logger.fine('Error showing immediate notification: $e');
    }
  }

  /// Play adzan
  Future<void> _playAdzan() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.setReleaseMode(ReleaseMode.stop);
      await audioPlayer.play(AssetSource('audio/adzan.mp3'));
      logger.fine('Playing adzan...');
    } catch (e) {
      logger.fine('Error playing adzan: $e');
    }
  }

  /// Play adzan for testing
  Future<void> playAdzanTest() async {
    await _playAdzan();
  }

  /// Stop adzan
  Future<void> stopAdzan() async {
    try {
      await audioPlayer.stop();
      logger.fine('Adzan stopped');
    } catch (e) {
      logger.fine('Error stopping adzan: $e');
    }
  }

  /// Helper untuk generate alarm key
  String _getAlarmKey(String prayerName) {
    return 'alarm_${prayerName.toLowerCase()}';
  }

  /// Helper untuk generate notification ID
  int _getNotificationId(String prayerName) {
    return prayerName.toLowerCase().hashCode;
  }

  /// Dispose service
  void dispose() {
    _checkTimer?.cancel();
    audioPlayer.dispose();
    _isInitialized = false;
  }
}
