import 'package:test_flutter/data/models/cache/cache.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';
import 'package:test_flutter/data/services/cache_service.dart';

class HomeCacheService {
  static final DateTime _sholatCacheExpiry = DateTime.now().add(
    Duration(hours: 12),
  );
  static final DateTime _articleCacheExpiry = DateTime.now().add(
    Duration(hours: 1),
  );

  // Cache keys
  static const String _jadwalSholatKey = 'home_jadwal_sholat';
  static const String _latestArticleKey = 'home_latest_article';

  // Cache jadwal sholat
  static Future<void> cacheJadwalSholat({
    required Sholat sholat,
    required double latitude,
    required double longitude,
  }) async {
    final key = '${_jadwalSholatKey}_${latitude}_$longitude';

    await CacheService.cacheData(
      key: key,
      data: sholat,
      dataType: 'jadwal_sholat',
      customExpiry: _sholatCacheExpiry,
    );

    // Cache metadata dengan lokasi
    CacheMetadata(
      lastFetch: DateTime.now(),
      totalPages: 1,
      currentPage: 1,
      totalItems: 1,
      cacheKey: key,
      customExpiry: _sholatCacheExpiry,
    );
  }

  // Get cached jadwal sholat
  static Sholat? getCachedJadwalSholat({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKey}_${latitude}_$longitude';

    return CacheService.getCachedData<Sholat>(
      key: key,
      fromJson: (json) => Sholat.fromJson(json as Map<String, dynamic>),
    );
  }

  // Cache latest articles
  static Future<void> cacheLatestArticle({
    required List<KomunitasArtikel> articles,
  }) async {
    await CacheService.cacheData(
      key: _latestArticleKey,
      data: articles,
      dataType: 'latest_article',
      customExpiry: _articleCacheExpiry,
    );
  }

  // Get cached latest articles
  static List<KomunitasArtikel> getCachedLatestArticle() {
    final cached = CacheService.getCachedData<List<KomunitasArtikel>>(
      key: _latestArticleKey,
      fromJson: (jsonData) {
        if (jsonData is List) {
          return jsonData
              .map(
                (item) =>
                    KomunitasArtikel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <KomunitasArtikel>[];
      },
    );

    return cached ?? [];
  }

  // Helper methods
  static bool hasCachedJadwalSholat({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKey}_${latitude}_$longitude';
    return CacheService.hasCachedData(key);
  }

  static bool hasCachedLatestArticle() {
    return CacheService.hasCachedData(_latestArticleKey);
  }

  static bool isJadwalSholatCacheValid({
    required double latitude,
    required double longitude,
  }) {
    final key = '${_jadwalSholatKey}_${latitude}_$longitude';
    return CacheService.isCacheValid(key);
  }

  static bool isLatestArticleCacheValid() {
    return CacheService.isCacheValid(_latestArticleKey);
  }

  static Future<void> clearAllCache() async {
    await CacheService.clearCache(_latestArticleKey);
    // Clear all sholat cache (multiple locations)
    // final cacheBox = CacheService._cacheBox;
    // if (cacheBox != null) {
    //   final keysToDelete = <String>[];
    //   for (final entry in cacheBox.values) {
    //     if (entry.key.startsWith(_jadwalSholatKey)) {
    //       keysToDelete.add(entry.key);
    //     }
    //   }
    //   for (final key in keysToDelete) {
    //     await CacheService.clearCache(key);
    //   }
    // }
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
