import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/location_service.dart';
import 'package:test_flutter/features/home/services/home_cache_service.dart';
import 'package:test_flutter/features/home/services/home_service.dart';

enum HomeState {
  initial,
  loadingLocation,
  loadingJadwalSholat,
  loadingLatestArticle,
  loadingAll,
  loadedJadwalSholat,
  loadedLatestArticle,
  loadedAll,
  error,
  refreshingLocation,
  refreshingJadwalSholat,
  refreshingLatestArticle,
  offline,
}

class HomeNotifier extends StateNotifier<Map<String, dynamic>> {
  HomeNotifier()
    : super({
        'status': HomeState.initial,
        'articles': <KomunitasArtikel>[],
        'jadwalSholat': null,
        'error': null,
        'lastLocation': null,
        'isOffline': false,
        'locationError': null,
      });

  // Load location and then jadwal sholat
  Future<void> loadLocationAndJadwalSholat() async {
    try {
      state = {...state, 'status': HomeState.loadingLocation};

      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        state = {
          ...state,
          'status': HomeState.error,
          'locationError':
              'Failed to get location. Please enable location services.',
        };
        return;
      }

      // Store location
      state = {
        ...state,
        'lastLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'locationError': null,
      };

      // Load jadwal sholat
      await loadJadwalSholat(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      logger.warning('Error loading location: $e');
      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load location: ${e.toString()}',
      };
    }
  }

  Future<void> loadJadwalSholat({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Set loading state
      state = {
        ...state,
        'status': HomeState.loadingJadwalSholat,
        'isOffline': false,
      };

      logger.fine('Loading jadwal sholat for location: $latitude, $longitude');

      // Try network first
      try {
        final resp = await HomeService.getJadwalSholat(
          latitude: latitude,
          longitude: longitude,
        );

        final sholat = resp['data'] as Sholat;

        // Cache the data
        await HomeCacheService.cacheJadwalSholat(
          sholat: sholat,
          latitude: latitude,
          longitude: longitude,
        );

        state = {
          ...state,
          'status': HomeState.loadedJadwalSholat,
          'jadwalSholat': sholat,
          'error': null,
          'isOffline': false,
          'lastLocation': {'latitude': latitude, 'longitude': longitude},
        };

        logger.fine('Jadwal sholat loaded successfully from network');
      } catch (networkError) {
        logger.warning('Network error, trying cache: $networkError');

        // Try to load from cache
        final cachedSholat = HomeCacheService.getCachedJadwalSholat(
          latitude: latitude,
          longitude: longitude,
        );

        if (cachedSholat != null) {
          state = {
            ...state,
            'status': HomeState.offline,
            'jadwalSholat': cachedSholat,
            'error':
                HomeCacheService.isJadwalSholatCacheValid(
                  latitude: latitude,
                  longitude: longitude,
                )
                ? null
                : 'Prayer schedule may not be up to date. No internet connection.',
            'isOffline': true,
          };

          logger.fine('Jadwal sholat loaded from cache');
        } else {
          state = {
            ...state,
            'status': HomeState.error,
            'error':
                'Failed to load prayer schedule: ${networkError.toString()}',
            'isOffline': true,
          };
        }
      }
    } catch (e) {
      logger.warning('Error loading jadwal sholat: $e');
      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load prayer schedule: ${e.toString()}',
      };
    }
  }

  Future<void> refreshJadwalSholat() async {
    final lastLocation = state['lastLocation'] as Map<String, dynamic>?;

    if (lastLocation == null) {
      await loadLocationAndJadwalSholat();
      return;
    }

    try {
      state = {...state, 'status': HomeState.refreshingJadwalSholat};

      await loadJadwalSholat(
        latitude: lastLocation['latitude'],
        longitude: lastLocation['longitude'],
      );
    } catch (e) {
      logger.warning('Error refreshing jadwal sholat: $e');
      state = {
        ...state,
        'status': HomeState.loadedJadwalSholat,
        'error': 'Failed to refresh prayer schedule: ${e.toString()}',
      };
    }
  }

  Future<void> loadLatestArticles() async {
    try {
      state = {...state, 'status': HomeState.loadingLatestArticle};

      logger.fine('Loading latest articles');

      // Try network first
      try {
        final resp = await HomeService.getLatestArticle();
        final articles = resp['data'] as List<KomunitasArtikel>;

        // Cache the data
        await HomeCacheService.cacheLatestArticle(articles: articles);

        state = {
          ...state,
          'status': HomeState.loadedLatestArticle,
          'articles': articles,
          'error': null,
          'isOffline': false,
        };

        logger.fine(
          'Latest articles loaded successfully: ${articles.length} articles',
        );
      } catch (networkError) {
        logger.warning('Network error, trying cache: $networkError');

        // Try to load from cache
        final cachedArticles = HomeCacheService.getCachedLatestArticle();

        if (cachedArticles.isNotEmpty) {
          state = {
            ...state,
            'status': HomeState.offline,
            'articles': cachedArticles,
            'error': HomeCacheService.isLatestArticleCacheValid()
                ? null
                : 'Articles may not be up to date. No internet connection.',
            'isOffline': true,
          };

          logger.fine(
            'Latest articles loaded from cache: ${cachedArticles.length} articles',
          );
        } else {
          state = {
            ...state,
            'status': HomeState.error,
            'error': 'Failed to load articles: ${networkError.toString()}',
            'isOffline': true,
          };
        }
      }
    } catch (e) {
      logger.warning('Error loading latest articles: $e');
      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load articles: ${e.toString()}',
      };
    }
  }

  Future<void> refreshLatestArticles() async {
    try {
      state = {...state, 'status': HomeState.refreshingLatestArticle};
      await loadLatestArticles();
    } catch (e) {
      logger.warning('Error refreshing latest articles: $e');
      state = {
        ...state,
        'status': HomeState.loadedLatestArticle,
        'error': 'Failed to refresh articles: ${e.toString()}',
      };
    }
  }

  Future<void> loadAllData() async {
    try {
      state = {...state, 'status': HomeState.loadingAll};

      // Load articles first (doesn't need location)
      await loadLatestArticles();

      // Load location and jadwal sholat
      await loadLocationAndJadwalSholat();

      // Check final state
      final hasJadwalSholat = state['jadwalSholat'] != null;
      final hasArticles = (state['articles'] as List).isNotEmpty;

      if (hasJadwalSholat && hasArticles) {
        state = {...state, 'status': HomeState.loadedAll};
      }
    } catch (e) {
      logger.warning('Error loading all data: $e');
      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to load data: ${e.toString()}',
      };
    }
  }

  // Refresh location dan jadwal sholat
  Future<void> refreshLocationAndJadwalSholat() async {
    try {
      state = {...state, 'status': HomeState.refreshingLocation};

      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        state = {
          ...state,
          'status': HomeState.error,
          'locationError':
              'Failed to get location. Please enable location services.',
        };
        return;
      }

      // Update location
      state = {
        ...state,
        'lastLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'locationError': null,
      };

      // Refresh jadwal sholat with new location
      await loadJadwalSholat(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      logger.warning('Error refreshing location: $e');
      state = {
        ...state,
        'status': HomeState.error,
        'error': 'Failed to refresh location: ${e.toString()}',
      };
    }
  }

  void clearError() {
    state = {...state, 'error': null, 'locationError': null};
  }

  // Helper methods for prayer times
  String? getCurrentPrayerTime() {
    final sholat = state['jadwalSholat'] as Sholat?;
    if (sholat == null) return null;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    // Find current prayer time
    for (int i = 0; i < prayerTimes.length; i++) {
      final prayerTime = prayerTimes[i]['time']!;
      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayerTime;
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
      final prayerTime = prayerTimes[i]['time']!;
      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayerTimes[i]['name'];
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
      final prayerTime = prayerTimes[i]['time']!;
      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        final minutesUntil =
            _timeToMinutes(prayerTime) - _timeToMinutes(currentTime);
        final hours = minutesUntil ~/ 60;
        final minutes = minutesUntil % 60;

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

  // Cache management
  Future<void> clearCache() async {
    await HomeCacheService.clearAllCache();
    logger.fine('Home cache cleared');
  }

  Map<String, int> getCacheInfo() {
    return HomeCacheService.getCacheInfo();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, Map<String, dynamic>>((
  ref,
) {
  return HomeNotifier();
});
