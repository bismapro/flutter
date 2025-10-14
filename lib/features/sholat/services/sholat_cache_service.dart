import 'package:test_flutter/core/constants/cache_keys.dart';
import 'package:test_flutter/data/models/cache/cache.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/cache/cache_service.dart';

class SholatCacheService {
  static const Duration _cacheDuration = Duration(hours: 12); // 14 hari

  // CACHE JADWAL SHOLAT
  static Future<void> cacheJadwalSholat(List<Sholat> jadwal) async {
    await CacheService.cacheData(
      key: CacheKeys.jadwalSholat,
      data: jadwal,
      dataType: 'jadwal_sholat',
      customExpiryDuration: _cacheDuration, // -> 4. Kirim sebagai Duration
    );
  }

  // CACHE PROGRESS HARI INI
  static Future<void> cacheProgressSholatWajibHariIni(
    Map<String, dynamic> progress,
  ) async {
    await CacheService.cacheData(
      key: CacheKeys.progressSholatWajibHariIni,
      data: progress,
      dataType: 'progress_sholat_wajib_hari_ini',
      customExpiryDuration: _cacheDuration,
    );
  }

  // CACHE PROGRESS WAJIB RIWAYAT
  static Future<void> cacheProgressSholatWajibRiwayat(
    Map<String, dynamic> progress,
  ) async {
    await CacheService.cacheData(
      key: CacheKeys.progressSholatWajibRiwayat,
      data: progress,
      dataType: 'progress_sholat_wajib_riwayat',
      customExpiryDuration: _cacheDuration,
    );
  }

  // CACHE PROGRESS SUNNAH RIWAYAT
  static Future<void> cacheProgressSholatSunnahRiwayat(
    Map<String, dynamic> progress,
  ) async {
    await CacheService.cacheData(
      key: CacheKeys.progressSholatSunnahRiwayat,
      data: progress,
      dataType: 'progress_sholat_wajib_riwayat',
      customExpiryDuration: _cacheDuration,
    );
  }

  // CACHE PROGRESS HARI INI
  static Future<void> cacheProgressSholatSunnahHariIni(
    Map<String, dynamic> progress,
  ) async {
    await CacheService.cacheData(
      key: CacheKeys.progressSholatSunnahHariIni,
      data: progress,
      dataType: 'progress_sholat_sunnah_hari_ini',
      customExpiryDuration: _cacheDuration,
    );
  }

  // GET JADWAL SHOLAT DARI CACHE
  static List<Sholat> getCachedJadwalSholat() {
    return CacheService.getCachedData<List<Sholat>>(
          key: CacheKeys.jadwalSholat, // -> 3. Gunakan key dari CacheKeys
          fromJson: (jsonData) {
            if (jsonData is List) {
              return jsonData
                  .map((item) => Sholat.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
            return [];
          },
        ) ??
        []; // Kembalikan list kosong jika null
  }

  // GET PROGRESS SHOLAT WAJIB HARI INI DARI CACHE
  static Map<String, dynamic> getCachedProgressSholatWajibHariIni() {
    return CacheService.getCachedData<Map<String, dynamic>>(
          key: CacheKeys.progressSholatWajibHariIni,
          fromJson: (jsonData) {
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
            }
            return {};
          },
        ) ??
        {};
  }

  // GET PROGRESS SHOLAT SUNNAH HARI INI DARI CACHE
  static Map<String, dynamic> getCachedProgressSholatSunnahHariIni() {
    return CacheService.getCachedData<Map<String, dynamic>>(
          key: CacheKeys.progressSholatSunnahHariIni,
          fromJson: (jsonData) {
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
            }
            return {};
          },
        ) ??
        {};
  }

  // GET PROGRESS SHOLAT WAJIB RIWAYAT DARI CACHE
  static Map<String, dynamic> getCachedProgressSholatWajibRiwayat() {
    return CacheService.getCachedData<Map<String, dynamic>>(
          key: CacheKeys.progressSholatWajibRiwayat,
          fromJson: (jsonData) {
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
            }
            return {};
          },
        ) ??
        {};
  }

  // GET PROGRESS SHOLAT SUNNAH RIWAYAT DARI CACHE
  static Map<String, dynamic> getCachedProgressSholatSunnahRiwayat() {
    return CacheService.getCachedData<Map<String, dynamic>>(
          key: CacheKeys.progressSholatSunnahRiwayat,
          fromJson: (jsonData) {
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
            }
            return {};
          },
        ) ??
        {};
  }

  static CacheMetadata? getCacheMetadata() {
    return CacheService.getCacheMetadata(CacheKeys.jadwalSholat);
  }

  static Future<void> clearCache() async {
    await CacheService.clearCache(CacheKeys.jadwalSholat);
    await CacheService.clearCache(CacheKeys.progressSholatWajibHariIni);
    await CacheService.clearCache(CacheKeys.progressSholatSunnahHariIni);
    await CacheService.clearCache(CacheKeys.progressSholatWajibRiwayat);
    await CacheService.clearCache(CacheKeys.progressSholatSunnahRiwayat);
  }
}
