import 'package:test_flutter/core/constants/cache_keys.dart';
import 'package:test_flutter/data/models/cache/cache.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/cache/cache_service.dart';

class SholatCacheService {
  static const Duration _cacheDuration = Duration(hours: 24 * 14); // 14 hari

  // CACHE JADWAL SHOLAT
  static Future<void> cacheJadwalSholat(List<Sholat> jadwal) async {
    await CacheService.cacheData(
      key: CacheKeys.jadwalSholat,
      data: jadwal,
      dataType: 'jadwal_sholat',
      customExpiryDuration: _cacheDuration, // -> 4. Kirim sebagai Duration
    );
  }

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

  static CacheMetadata? getCacheMetadata() {
    return CacheService.getCacheMetadata(CacheKeys.jadwalSholat);
  }

  static Future<void> clearCache() async {
    await CacheService.clearCache(CacheKeys.jadwalSholat);
  }
}
