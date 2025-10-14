import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/location/location_service.dart';
import 'package:test_flutter/features/sholat/services/sholat_cache_service.dart';
import 'package:test_flutter/features/sholat/services/sholat_service.dart';
import 'package:test_flutter/features/sholat/sholat_state.dart';

final sholatProvider = StateNotifierProvider<SholatProvider, SholatState>((
  ref,
) {
  return SholatProvider();
});

class SholatProvider extends StateNotifier<SholatState> {
  SholatProvider() : super(SholatState.initial()) {
    _loadCachedData();
  }

  /// Load cached data saat inisialisasi
  Future<void> _loadCachedData() async {
    final cachedJadwal = SholatCacheService.getCachedJadwalSholat();
    final cachedLocation = await LocationService.getLocation();

    if (cachedJadwal.isNotEmpty) {
      logger.info('Loaded ${cachedJadwal.length} cached jadwal sholat');

      // Update state dengan jadwal dan lokasi dari cache
      state = state.copyWith(
        sholatList: cachedJadwal,
        latitude: cachedLocation?['lat'] as double?,
        longitude: cachedLocation?['long'] as double?,
        locationName: cachedLocation?['name'] as String?,
        localDate: cachedLocation?['date'] as String?,
        localTime: cachedLocation?['time'] as String?,
        isOffline: false,
      );
    } else if (cachedLocation != null) {
      // Jika ada lokasi tapi belum ada jadwal, set lokasi saja
      state = state.copyWith(
        latitude: cachedLocation['lat'] as double?,
        longitude: cachedLocation['long'] as double?,
        locationName: cachedLocation['name'] as String?,
        localDate: cachedLocation['date'] as String?,
        localTime: cachedLocation['time'] as String?,
      );
    }
  }

  /// Fetch jadwal sholat dengan strategi network-first-then-cache
  Future<void> fetchJadwalSholat({
    double? latitude,
    double? longitude,
    String? locationName,
    String? localDate,
    String? localTime,
    bool forceRefresh = false,
    bool useCurrentLocation = false,
  }) async {
    // Jika useCurrentLocation = true, ambil lokasi real-time
    if (useCurrentLocation) {
      logger.info('Fetching current location...');
      state = state.copyWith(status: SholatStatus.loading);

      final locationData = await LocationService.getCurrentLocation();
      latitude = locationData['lat'] as double;
      longitude = locationData['long'] as double;
      locationName = locationData['name'] as String;
      localDate = locationData['date'] as String;
      localTime = locationData['time'] as String;

      logger.info(
        'Location obtained: $locationName ($latitude, $longitude) | $localDate $localTime',
      );
    } else {
      // Jika tidak ada parameter, gunakan dari state atau cache
      latitude ??= state.latitude;
      longitude ??= state.longitude;
      locationName ??= state.locationName;
      localDate ??= state.localDate;
      localTime ??= state.localTime;

      // Jika masih null, ambil dari cache
      if (latitude == null || longitude == null) {
        final cachedLocation = await LocationService.getLocation();
        if (cachedLocation != null) {
          latitude = cachedLocation['lat'] as double;
          longitude = cachedLocation['long'] as double;
          locationName = cachedLocation['name'] as String;
          localDate = cachedLocation['date'] as String;
          localTime = cachedLocation['time'] as String;
        }
      }

      // Jika masih null, ambil lokasi saat ini
      if (latitude == null || longitude == null) {
        logger.info('No location available, fetching current location...');
        final locationData = await LocationService.getCurrentLocation();
        latitude = locationData['lat'] as double;
        longitude = locationData['long'] as double;
        locationName = locationData['name'] as String;
        localDate = locationData['date'] as String;
        localTime = locationData['time'] as String;
      }
    }

    // Jika sudah ada data dan bukan force refresh, skip
    if (!forceRefresh && state.sholatList.isNotEmpty && !useCurrentLocation) {
      logger.info('Using existing jadwal sholat data');
      return;
    }

    state = state.copyWith(
      status: forceRefresh ? SholatStatus.refreshing : SholatStatus.loading,
    );

    try {
      // 1. Try network first
      final response = await SholatService.getJadwalSholat(
        latitude: latitude,
        longitude: longitude,
      );

      final sholatList = response['data'] as List<Sholat>;

      // 2. Cache the fetched data
      await SholatCacheService.cacheJadwalSholat(sholatList);

      // 3. Update state with network data
      state = state.copyWith(
        status: SholatStatus.loaded,
        sholatList: sholatList,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        localDate: localDate,
        localTime: localTime,
        isOffline: false,
        message: 'Jadwal sholat berhasil diperbarui',
      );

      logger.info('Successfully fetched and cached jadwal sholat');
    } catch (e) {
      logger.severe('Error fetching jadwal sholat: $e');

      // 4. Fallback to cache if network fails
      final cachedJadwal = SholatCacheService.getCachedJadwalSholat();

      if (cachedJadwal.isNotEmpty) {
        logger.info('Using cached jadwal sholat due to network error');
        state = state.copyWith(
          status: SholatStatus.offline,
          sholatList: cachedJadwal,
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          localDate: localDate,
          localTime: localTime,
          isOffline: true,
          message: 'Menggunakan data offline',
        );
      } else {
        logger.warning('No cached data available');
        state = state.copyWith(
          status: SholatStatus.error,
          message: 'Gagal mengambil jadwal sholat: $e',
          isOffline: true,
        );
      }
    }
  }

  /// Refresh jadwal sholat dengan lokasi yang sudah ada
  Future<void> refreshJadwalSholat() async {
    if (state.latitude == null || state.longitude == null) {
      logger.warning('Cannot refresh: location not available');

      // Coba ambil dari cache
      final cachedLocation = await LocationService.getLocation();
      if (cachedLocation == null) {
        logger.warning(
          'No cached location available, will fetch current location',
        );
        await fetchJadwalSholat(useCurrentLocation: true);
        return;
      }
    }

    await fetchJadwalSholat(
      latitude: state.latitude,
      longitude: state.longitude,
      locationName: state.locationName,
      localDate: state.localDate,
      localTime: state.localTime,
      forceRefresh: true,
    );
  }

  /// Update lokasi dan fetch jadwal baru
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String locationName,
    String? localDate,
    String? localTime,
  }) async {
    logger.info('Updating location to: $locationName ($latitude, $longitude)');

    // Fetch jadwal dengan lokasi baru
    await fetchJadwalSholat(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      localDate: localDate,
      localTime: localTime,
      forceRefresh: true,
    );
  }

  /// Gunakan lokasi saat ini
  Future<void> useCurrentLocation() async {
    await fetchJadwalSholat(useCurrentLocation: true);
  }

  /// Get jadwal untuk tanggal tertentu
  Sholat? getJadwalByDate(DateTime date) {
    final formatter = DateFormat('dd-MM-yyyy');
    final dateString = formatter.format(date);

    try {
      return state.sholatList.firstWhere(
        (jadwal) => jadwal.tanggal == dateString,
      );
    } catch (e) {
      logger.warning('Jadwal not found for date: $dateString');
      return null;
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await SholatCacheService.clearCache();
    await LocationService.clear();
    state = SholatState.initial();
    logger.info('Cleared all sholat cache and location');
  }
}
