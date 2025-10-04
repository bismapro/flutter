import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat.dart';
import 'package:test_flutter/features/home/home_service.dart';

enum HomeState {
  initial,
  loadingArtikel,
  loadingSholat,
  loadedArtikel,
  loadedSholat,
  loadedAll,
  error,
  refreshingSholat,
}

class HomeNotifier extends StateNotifier<Map<String, dynamic>> {
  HomeNotifier()
    : super({
        'status': HomeState.initial,
        'articles': <KomunitasArtikel>[],
        'jadwalSholat': null,
        'error': null,
        'lastLocation': null,
      });

  Future<void> loadJadwalSholat({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Set loading state
      state = {
        ...state,
        'status': state['status'] == HomeState.loadedArtikel
            ? HomeState.loadedArtikel
            : HomeState.loadingSholat,
        'error': null,
        'lastLocation': {'latitude': latitude, 'longitude': longitude},
      };

      final resp = await HomeService.getJadwalSholat(
        latitude: latitude,
        longitude: longitude,
      );

      logger.fine('Get jadwal sholat response: $resp');

      final sholat = resp['data'] as Sholat;
      final hasArticles =
          (state['articles'] as List<KomunitasArtikel>).isNotEmpty;

      state = {
        ...state,
        'status': hasArticles ? HomeState.loadedAll : HomeState.loadedSholat,
        'jadwalSholat': sholat,
        'error': null,
      };
    } catch (e) {
      logger.warning('Error load jadwal sholat: $e');

      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load jadwal sholat: ${e.toString()}',
      };
    }
  }

  Future<void> refreshJadwalSholat() async {
    final lastLocation = state['lastLocation'] as Map<String, dynamic>?;

    if (lastLocation == null) {
      state = {...state, 'error': 'No location data available for refresh'};
      return;
    }

    try {
      state = {...state, 'status': HomeState.refreshingSholat, 'error': null};

      final resp = await HomeService.getJadwalSholat(
        latitude: lastLocation['latitude'],
        longitude: lastLocation['longitude'],
      );

      logger.fine('Refresh jadwal sholat response: $resp');

      final sholat = resp['data'] as Sholat;
      final hasArticles =
          (state['articles'] as List<KomunitasArtikel>).isNotEmpty;

      state = {
        ...state,
        'status': hasArticles ? HomeState.loadedAll : HomeState.loadedSholat,
        'jadwalSholat': sholat,
        'error': null,
      };
    } catch (e) {
      logger.warning('Error refresh jadwal sholat: $e');

      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to refresh jadwal sholat: ${e.toString()}',
      };
    }
  }

  Future<void> loadLatestArticles() async {
    try {
      // Set loading state
      state = {
        ...state,
        'status': state['status'] == HomeState.loadedSholat
            ? HomeState.loadedSholat
            : HomeState.loadingArtikel,
        'error': null,
      };

      final resp = await HomeService.getLatestArticle();
      logger.fine('Get latest articles response: $resp');

      final articles = resp['data'] as List<KomunitasArtikel>;
      final hasSholat = state['jadwalSholat'] != null;

      state = {
        ...state,
        'status': hasSholat ? HomeState.loadedAll : HomeState.loadedArtikel,
        'articles': articles,
        'error': null,
      };
    } catch (e) {
      logger.warning('Error load articles: $e');

      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load articles: ${e.toString()}',
      };
    }
  }

  Future<void> loadAllData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      state = {
        ...state,
        'status': HomeState.initial,
        'error': null,
        'lastLocation': {'latitude': latitude, 'longitude': longitude},
      };

      // Load both in parallel
      final futures = await Future.wait([
        HomeService.getJadwalSholat(latitude: latitude, longitude: longitude),
        HomeService.getLatestArticle(),
      ]);

      final sholatResp = futures[0];
      final articlesResp = futures[1];

      final sholat = sholatResp['data'] as Sholat;
      final articles = articlesResp['data'] as List<KomunitasArtikel>;

      state = {
        ...state,
        'status': HomeState.loadedAll,
        'jadwalSholat': sholat,
        'articles': articles,
        'error': null,
      };
    } catch (e) {
      logger.warning('Error load all data: $e');

      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load data: ${e.toString()}',
      };
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }

  // Helper methods
  String? getCurrentPrayerTime() {
    final sholat = state['jadwalSholat'] as Sholat?;
    if (sholat == null) return null;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    // Find current prayer time
    for (int i = 0; i < prayerTimes.length; i++) {
      final prayer = prayerTimes[i];
      final prayerTime = prayer['time']!;

      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayer['time'];
      }
    }

    // If past all prayers for today, return first prayer of next day
    return prayerTimes.first['time'];
  }

  String? getCurrentPrayerName() {
    final sholat = state['jadwalSholat'] as Sholat?;
    if (sholat == null) return null;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    // Find current prayer name
    for (int i = 0; i < prayerTimes.length; i++) {
      final prayer = prayerTimes[i];
      final prayerTime = prayer['time']!;

      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayer['name'];
      }
    }

    // If past all prayers for today, return first prayer of next day
    return prayerTimes.first['name'];
  }

  String? getTimeUntilNextPrayer() {
    final sholat = state['jadwalSholat'] as Sholat?;
    if (sholat == null) return null;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    // Find next prayer time
    for (int i = 0; i < prayerTimes.length; i++) {
      final prayer = prayerTimes[i];
      final prayerTime = prayer['time']!;

      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        final diffMinutes =
            _timeToMinutes(prayerTime) - _timeToMinutes(currentTime);
        final hours = diffMinutes ~/ 60;
        final minutes = diffMinutes % 60;

        if (hours > 0) {
          return '$hours hour $minutes min left';
        } else {
          return '$minutes min left';
        }
      }
    }

    // If past all prayers for today, calculate time until first prayer of next day
    final firstPrayerTime = prayerTimes.first['time']!;
    final minutesUntilMidnight = (24 * 60) - _timeToMinutes(currentTime);
    final minutesFromMidnight = _timeToMinutes(firstPrayerTime);
    final totalMinutes = minutesUntilMidnight + minutesFromMidnight;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '$hours hour $minutes min left';
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, Map<String, dynamic>>((
  ref,
) {
  return HomeNotifier();
});
