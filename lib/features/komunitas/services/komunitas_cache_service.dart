import 'package:test_flutter/data/models/cache/cache.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/services/cache_service.dart';

class KomunitasCacheService {
  static final DateTime cacheExpiry = DateTime.now().add(
    const Duration(hours: 2),
  );

  // Cache komunitas artikel
  static Future<void> cacheArtikel({
    required List<KomunitasArtikel> artikel,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    bool isLoadMore = false,
  }) async {
    await CacheService.cachePaginatedData<KomunitasArtikel>(
      key: CacheService.komunitasArtikelKey,
      data: artikel,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      dataType: 'komunitas_artikel',
      isLoadMore: isLoadMore,
      customExpiry: cacheExpiry,
    );
  }

  // Get cached artikel - DIPERBAIKI
  static List<KomunitasArtikel> getCachedArtikel() {
    final cached = CacheService.getCachedData<List<KomunitasArtikel>>(
      key: CacheService.komunitasArtikelKey,
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

  // Cache single artikel detail
  static Future<void> cacheArtikelDetail(KomunitasArtikel artikel) async {
    await CacheService.cacheData(
      key: '${CacheService.komunitasArtikelKey}_detail_${artikel.id}',
      data: artikel,
      dataType: 'komunitas_artikel_detail',
      customExpiry: cacheExpiry,
    );
  }

  // Get cached artikel detail
  static KomunitasArtikel? getCachedArtikelDetail(String id) {
    return CacheService.getCachedData<KomunitasArtikel>(
      key: '${CacheService.komunitasArtikelKey}_detail_$id',
      fromJson: (json) =>
          KomunitasArtikel.fromJson(json as Map<String, dynamic>),
    );
  }

  // Cache comments
  static Future<void> cacheComments({
    required String artikelId,
    required List<KomunitasKomentar> comments,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    bool isLoadMore = false,
  }) async {
    await CacheService.cachePaginatedData<KomunitasKomentar>(
      key: '${CacheService.komunitasArtikelKey}_comments_$artikelId',
      data: comments,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      dataType: 'komunitas_comments',
      isLoadMore: isLoadMore,
      customExpiry: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  // Get cached comments
  static List<KomunitasKomentar> getCachedComments(String artikelId) {
    final cached = CacheService.getCachedData<List<KomunitasKomentar>>(
      key: '${CacheService.komunitasArtikelKey}_comments_$artikelId',
      fromJson: (jsonData) {
        if (jsonData is List) {
          return jsonData
              .map(
                (item) =>
                    KomunitasKomentar.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <KomunitasKomentar>[];
      },
    );

    return cached ?? [];
  }

  // Helper methods
  static bool hasCachedArtikel() {
    return CacheService.hasCachedData(CacheService.komunitasArtikelKey);
  }

  static bool isCacheValid() {
    return CacheService.isCacheValid(CacheService.komunitasArtikelKey);
  }

  static CacheMetadata? getCacheMetadata() {
    return CacheService.getCacheMetadata(CacheService.komunitasArtikelKey);
  }

  static Future<void> clearCache() async {
    await CacheService.clearCache(CacheService.komunitasArtikelKey);
  }

  static Map<String, int> getCacheInfo() {
    final info = CacheService.getCacheInfo();
    final types = info['types'] as Map<String, dynamic>? ?? {};

    return {
      'artikel_count': types['komunitas_artikel'] ?? 0,
      'artikel_detail_count': types['komunitas_artikel_detail'] ?? 0,
      'comments_count': types['komunitas_comments'] ?? 0,
    };
  }
}
