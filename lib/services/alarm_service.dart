import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AudioPlayer audioPlayer;
  Timer? _checkTimer;

  // Prayer names and their corresponding times (this should be updated with actual prayer times)
  final Map<String, String> _prayerTimes = {
    'Fajr': '05:41',
    'Dhuhr': '12:00',
    'Asr': '15:14',
    'Maghrib': '18:02',
    'Isha': '19:11',
  };

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

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
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          await _playAdzan();
        }
      },
    );

    // Request permissions for notifications
    await _requestPermissions();

    // Start checking for prayer times
    _startPrayerTimeChecker();
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

  Future<void> setAlarm(String prayerName, bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_$prayerName', enabled);

    if (enabled) {
      // Schedule notification for this prayer
      await _scheduleNotification(prayerName);
    } else {
      // Cancel notification for this prayer
      await _cancelNotification(prayerName);
    }
  }

  Future<bool> isAlarmEnabled(String prayerName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('alarm_$prayerName') ?? false;
  }

  Future<void> _scheduleNotification(String prayerName) async {
    if (!_prayerTimes.containsKey(prayerName)) return;

    final String timeStr = _prayerTimes[prayerName]!;
    final DateTime now = DateTime.now();
    final List<String> timeParts = timeStr.split(':');
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

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'prayer_alarm_channel',
          'Prayer Alarms',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          enableVibration: true,
          playSound: false, // We'll handle sound separately
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          sound: null, // We'll handle sound separately
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'Waktu Sholat $prayerName',
      'Saatnya melaksanakan sholat $prayerName',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: prayerName,
    );
  }

  Future<void> _cancelNotification(String prayerName) async {
    await flutterLocalNotificationsPlugin.cancel(prayerName.hashCode);
  }

  void _startPrayerTimeChecker() {
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkPrayerTimes();
    });
  }

  Future<void> _checkPrayerTimes() async {
    final DateTime now = DateTime.now();
    final String currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (String prayerName in _prayerTimes.keys) {
      if (_prayerTimes[prayerName] == currentTime) {
        bool isEnabled = await isAlarmEnabled(prayerName);
        if (isEnabled) {
          await _playAdzan();
          await _showNotification(prayerName);
          // Reschedule for next day
          await _scheduleNotification(prayerName);
        }
      }
    }
  }

  Future<void> _showNotification(String prayerName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'prayer_now_channel',
          'Prayer Time Now',
          channelDescription: 'Current prayer time notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          enableVibration: true,
          playSound: false,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(sound: null);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Waktu Sholat $prayerName',
      'Saatnya melaksanakan sholat $prayerName. Semoga Allah menerima ibadah Anda.',
      platformChannelSpecifics,
    );
  }

  Future<void> _playAdzan() async {
    try {
      await audioPlayer.stop(); // Stop any currently playing audio
      await audioPlayer.play(AssetSource('audio/adzan.mp3'));
    } catch (e) {
      debugPrint('Error playing adzan: $e');
    }
  }

  Future<void> playAdzanTest() async {
    await _playAdzan();
  }

  Future<void> stopAdzan() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping adzan: $e');
    }
  }

  Future<void> updatePrayerTime(String prayerName, String time) async {
    _prayerTimes[prayerName] = time;

    // If alarm is enabled, reschedule the notification
    bool isEnabled = await isAlarmEnabled(prayerName);
    if (isEnabled) {
      await _cancelNotification(prayerName);
      await _scheduleNotification(prayerName);
    }
  }

  Future<Map<String, bool>> getAllAlarmStates() async {
    Map<String, bool> alarmStates = {};
    for (String prayerName in _prayerTimes.keys) {
      alarmStates[prayerName] = await isAlarmEnabled(prayerName);
    }
    return alarmStates;
  }

  void dispose() {
    _checkTimer?.cancel();
    audioPlayer.dispose();
  }
}
