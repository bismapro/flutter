import 'package:test_flutter/data/models/sedekah/sedekah.dart';
import 'package:test_flutter/data/services/cache_service.dart';

class SedekahCacheService {
  static final DateTime cacheExpiry = DateTime.now().add(
    const Duration(hours: 24),
  );

  // Cache statistik sedekah
  static Future<void> cacheSedekahStats({
    required StatistikSedekah stats,
  }) async {
    await CacheService.cacheData<StatistikSedekah>(
      key: CacheService.sedekahStatsKey,
      data: stats,
      dataType: 'sedekah_stats',
      customExpiry: cacheExpiry,
    );
  }

  // Get cached statistik sedekah
  static StatistikSedekah? getCacheSedekahStats() {
    final cached = CacheService.getCachedData<StatistikSedekah>(
      key: CacheService.sedekahStatsKey,
      fromJson: (jsonData) {
        if (jsonData is Map<String, dynamic>) {
          return StatistikSedekah.fromJson(jsonData);
        }

        return StatistikSedekah(totalHariIni: 0, totalBulanIni: 0, riwayat: []);
      },
    );

    return cached;
  }

  // Helper methods
  static bool hasCachedSedekahStats() {
    return CacheService.hasCachedData(CacheService.sedekahStatsKey);
  }
}
