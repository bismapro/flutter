import 'package:test_flutter/core/constants/cache_keys.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/cache/cache_service.dart';

class HomeCacheService {
  static const Duration _sholatCacheDuration = Duration(hours: 12);
  static const Duration _articleCacheDuration = Duration(hours: 1);

  // Cache keys base (akan ditambah dengan koordinat untuk jadwal sholat)
  static const String _jadwalSholatKeyBase = 'test';
  static const String _latestArticleKey = CacheKeys.homeLatestArticle;

  // ==================== Jadwal Sholat Cache ====================

  static Future<void> cacheJadwalSholat({
    required Sholat sholat,
    required double latitude,
    required double longitude,
  }) async {
    final key = '${_jadwalSholatKeyBase}_${latitude}_$longitude';

    await CacheService.cacheData(
      key: key,
      data: sholat,
      dataType: 'jadwal_sholat',
      customExpiryDuration: _sholatCacheDuration,
    );
  }

  static Sholat? getCachedJadwalSholat({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKeyBase}_${latitude}_$longitude';

    return CacheService.getCachedData<Sholat>(
      key: key,
      fromJson: (jsonData) {
        if (jsonData is Map<String, dynamic>) {
          return Sholat.fromJson(jsonData);
        }
        throw Exception('Invalid jadwal sholat data format');
      },
    );
  }

  static bool hasCachedJadwalSholat({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKeyBase}_${latitude}_$longitude';
    return CacheService.hasCachedData(key);
  }

  static bool isJadwalSholatCacheValid({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKeyBase}_${latitude}_$longitude';
    return CacheService.isCacheValid(key);
  }

  // ==================== Latest Article Cache ====================

  static Future<void> cacheLatestArticle({
    required List<KomunitasPostingan> articles,
  }) async {
    await CacheService.cacheData(
      key: _latestArticleKey,
      data: articles,
      dataType: 'latest_article',
      customExpiryDuration: _articleCacheDuration,
    );
  }

  static List<KomunitasPostingan> getCachedLatestArticle() {
    return CacheService.getCachedData<List<KomunitasPostingan>>(
          key: _latestArticleKey,
          fromJson: (jsonData) {
            if (jsonData is List) {
              return jsonData
                  .map(
                    (item) =>
                        KomunitasPostingan.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
            }
            return <KomunitasPostingan>[];
          },
        ) ??
        [];
  }

  static bool hasCachedLatestArticle() {
    return CacheService.hasCachedData(_latestArticleKey);
  }

  static bool isLatestArticleCacheValid() {
    return CacheService.isCacheValid(_latestArticleKey);
  }

  // ==================== Cache Management ====================

  static Future<void> clearAllCache() async {
    // Clear latest article cache
    await CacheService.clearCache(_latestArticleKey);

    // Clear all jadwal sholat caches (multiple locations)
    final allKeys = CacheService.getAllCacheKeys();
    for (final key in allKeys) {
      if (key.startsWith(_jadwalSholatKeyBase)) {
        await CacheService.clearCache(key);
      }
    }
  }

  static Map<String, int> getCacheInfo() {
    final info = CacheService.getCacheInfo();
    final types = info['types'] as Map<String, dynamic>? ?? {};

    return {
      'jadwal_sholat_count': types['jadwal_sholat'] ?? 0,
      'latest_article_count': types['latest_article'] ?? 0,
    };
  }
}
