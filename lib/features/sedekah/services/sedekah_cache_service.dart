import 'package:test_flutter/core/constants/cache_keys.dart';
import 'package:test_flutter/data/models/sedekah/sedekah.dart';
import 'package:test_flutter/data/services/cache/cache_service.dart';

class SedekahCacheService {
  static const Duration _cacheDuration = Duration(hours: 24);

  static Future<void> cacheSedekah(StatistikSedekah stats) async {
    await CacheService.cacheData(
      key: CacheKeys.sedekah,
      data: stats,
      dataType: 'sedekah',
      customExpiryDuration: _cacheDuration,
    );
  }

  static StatistikSedekah getCachedSedekah() {
    return CacheService.getCachedData<StatistikSedekah>(
          key: CacheKeys.sedekah,
          fromJson: (jsonData) {
            if (jsonData is Map<String, dynamic>) {
              return StatistikSedekah.fromJson(jsonData);
            }
            return StatistikSedekah.empty();
          },
        ) ??
        StatistikSedekah.empty();
  }

  // Helper methods
  static bool hasCachedSedekah() {
    return CacheService.hasCachedData(CacheKeys.sedekah);
  }
}
