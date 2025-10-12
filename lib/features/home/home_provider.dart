import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/services/location_service.dart';
import 'package:test_flutter/features/home/home_state.dart';
import 'package:test_flutter/features/home/services/home_cache_service.dart';
import 'package:test_flutter/features/home/services/home_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState.initial()) {
    _initializeTimezone();
  }

  // Initialize timezone data
  void _initializeTimezone() {
    try {
      tz.initializeTimeZones();
    } catch (e) {
      logger.warning('Failed to initialize timezones: $e');
    }
  }

  // Get timezone based on latitude and longitude
  String _getTimezoneFromLocation(double latitude, double longitude) {
    if (latitude >= -11 &&
        latitude <= 6 &&
        longitude >= 95 &&
        longitude <= 141) {
      if (longitude >= 95 && longitude <= 105) {
        return 'Asia/Jakarta'; // WIB (UTC+7)
      } else if (longitude >= 105 && longitude <= 120) {
        return 'Asia/Makassar'; // WITA (UTC+8)
      } else if (longitude >= 120 && longitude <= 141) {
        return 'Asia/Jayapura'; // WIT (UTC+9)
      }
    }
    return 'Asia/Jakarta';
  }

  // Get current time based on location
  DateTime _getCurrentTimeForLocation() {
    final location = state.lastLocation;
    if (location == null) {
      return DateTime.now();
    }

    final latitude = location['latitude'] as double;
    final longitude = location['longitude'] as double;

    try {
      final timezoneName = _getTimezoneFromLocation(latitude, longitude);
      final timezone = tz.getLocation(timezoneName);
      return tz.TZDateTime.now(timezone);
    } catch (e) {
      logger.warning('Failed to get timezone time: $e');
      return DateTime.now();
    }
  }

  // Load all data when page loads
  Future<void> loadAllData() async {
    try {
      state = state.copyWith(status: HomeStatus.loading);

      // Load articles first (doesn't need location)
      await _loadLatestArticlesInternal();

      // Load location and jadwal sholat
      await _loadLocationAndJadwalSholatInternal();

      // Check final state
      final hasJadwalSholat = state.jadwalSholat != null;
      final hasArticles = state.articles.isNotEmpty;

      if (hasJadwalSholat && hasArticles) {
        state = state.copyWith(status: HomeStatus.loaded);
      }
    } catch (e) {
      logger.warning('Error loading all data: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to load data: ${e.toString()}',
      );
    }
  }

  // Internal method to load location and jadwal sholat
  Future<void> _loadLocationAndJadwalSholatInternal() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        state = state.copyWith(
          status: HomeStatus.error,
          locationError:
              'Failed to get location. Please enable location services.',
        );
        return;
      }

      // Store location
      state = state.copyWith(
        lastLocation: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        clearLocationError: true,
      );

      // Load jadwal sholat
      await _loadJadwalSholatInternal(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      logger.warning('Error loading location: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to load location: ${e.toString()}',
      );
    }
  }

  // Internal method to load jadwal sholat
  Future<void> _loadJadwalSholatInternal({
    required double latitude,
    required double longitude,
  }) async {
    try {
      logger.fine('Loading jadwal sholat for location: $latitude, $longitude');

      // Try network first
      try {
        final resp = await HomeService.getJadwalSholat(
          latitude: latitude,
          longitude: longitude,
        );

        final sholat = resp['data'];

        // Cache the data
        await HomeCacheService.cacheJadwalSholat(
          sholat: sholat,
          latitude: latitude,
          longitude: longitude,
        );

        state = state.copyWith(
          jadwalSholat: sholat,
          clearError: true,
          isOffline: false,
        );

        logger.fine('Jadwal sholat loaded successfully from network');
      } catch (networkError) {
        logger.warning('Network error, trying cache: $networkError');

        // Try to load from cache
        final cachedSholat = HomeCacheService.getCachedJadwalSholat(
          latitude: latitude,
          longitude: longitude,
        );

        if (cachedSholat != null) {
          state = state.copyWith(
            status: HomeStatus.offline,
            jadwalSholat: cachedSholat,
            error:
                HomeCacheService.isJadwalSholatCacheValid(
                  latitude: latitude,
                  longitude: longitude,
                )
                ? null
                : 'Prayer schedule may not be up to date. No internet connection.',
            isOffline: true,
          );

          logger.fine('Jadwal sholat loaded from cache');
        } else {
          state = state.copyWith(
            status: HomeStatus.error,
            error: 'Failed to load prayer schedule: ${networkError.toString()}',
            isOffline: true,
          );
        }
      }
    } catch (e) {
      logger.warning('Error loading jadwal sholat: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to load prayer schedule: ${e.toString()}',
      );
    }
  }

  // Internal method to load latest articles
  Future<void> _loadLatestArticlesInternal() async {
    try {
      logger.fine('Loading latest articles');

      // Try network first
      try {
        final resp = await HomeService.getLatestArticle();
        final articles = resp['data'];

        // Cache the data
        await HomeCacheService.cacheLatestArticle(articles: articles);

        state = state.copyWith(
          articles: articles,
          clearError: true,
          isOffline: false,
        );

        logger.fine(
          'Latest articles loaded successfully: ${articles.length} articles',
        );
      } catch (networkError) {
        logger.warning('Network error, trying cache: $networkError');

        // Try to load from cache
        final cachedArticles = HomeCacheService.getCachedLatestArticle();

        if (cachedArticles.isNotEmpty) {
          state = state.copyWith(
            status: HomeStatus.offline,
            articles: cachedArticles,
            error: HomeCacheService.isLatestArticleCacheValid()
                ? null
                : 'Articles may not be up to date. No internet connection.',
            isOffline: true,
          );

          logger.fine(
            'Latest articles loaded from cache: ${cachedArticles.length} articles',
          );
        } else {
          state = state.copyWith(
            status: HomeStatus.error,
            error: 'Failed to load articles: ${networkError.toString()}',
            isOffline: true,
          );
        }
      }
    } catch (e) {
      logger.warning('Error loading latest articles: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to load articles: ${e.toString()}',
      );
    }
  }

  // Public method to refresh location and jadwal sholat
  Future<void> refreshLocationAndJadwalSholat() async {
    try {
      state = state.copyWith(status: HomeStatus.refreshing);

      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        state = state.copyWith(
          status: HomeStatus.error,
          locationError:
              'Failed to get location. Please enable location services.',
        );
        return;
      }

      // Update location
      state = state.copyWith(
        lastLocation: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        clearLocationError: true,
      );

      // Refresh jadwal sholat with new location
      await _loadJadwalSholatInternal(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(status: HomeStatus.loaded);
    } catch (e) {
      logger.warning('Error refreshing location: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to refresh location: ${e.toString()}',
      );
    }
  }

  // Public method to refresh latest articles
  Future<void> refreshLatestArticles() async {
    try {
      state = state.copyWith(status: HomeStatus.refreshing);
      await _loadLatestArticlesInternal();
      state = state.copyWith(status: HomeStatus.loaded);
    } catch (e) {
      logger.warning('Error refreshing latest articles: $e');
      state = state.copyWith(
        status: HomeStatus.error,
        error: 'Failed to refresh articles: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, clearLocationError: true);
  }

  // Helper methods for prayer times
  String? getCurrentPrayerTime() {
    final sholat = state.jadwalSholat;
    if (sholat == null) return null;

    final now = _getCurrentTimeForLocation();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    for (int i = 0; i < prayerTimes.length; i++) {
      final prayerTime = prayerTimes[i]['time']!;
      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayerTime;
      }
    }

    return prayerTimes.first['time'];
  }

  String? getCurrentPrayerName() {
    final sholat = state.jadwalSholat;
    if (sholat == null) return null;

    final now = _getCurrentTimeForLocation();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

    for (int i = 0; i < prayerTimes.length; i++) {
      final prayerTime = prayerTimes[i]['time']!;
      if (_timeToMinutes(currentTime) < _timeToMinutes(prayerTime)) {
        return prayerTimes[i]['name'];
      }
    }

    return prayerTimes.first['name'];
  }

  String? getTimeUntilNextPrayer() {
    final sholat = state.jadwalSholat;
    if (sholat == null) return null;

    final now = _getCurrentTimeForLocation();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTimes = sholat.wajib.getAllPrayerTimes();

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

    final firstPrayerTime = prayerTimes.first['time']!;
    final minutesUntilMidnight = (24 * 60) - _timeToMinutes(currentTime);
    final minutesFromMidnight = _timeToMinutes(firstPrayerTime);
    final totalMinutes = minutesUntilMidnight + minutesFromMidnight;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '$hours hour $minutes min left';
  }

  String getCurrentTimeString() {
    final now = _getCurrentTimeForLocation();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String getCurrentTimezone() {
    final location = state.lastLocation;
    if (location == null) {
      return 'Unknown';
    }

    final latitude = location['latitude'] as double;
    final longitude = location['longitude'] as double;

    return _getTimezoneFromLocation(latitude, longitude);
  }

  // Cache management
  Future<void> clearCache() async {
    await HomeCacheService.clearAllCache();
    logger.fine('Home cache cleared');
  }

  Map<String, int> getCacheInfo() {
    return HomeCacheService.getCacheInfo();
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
