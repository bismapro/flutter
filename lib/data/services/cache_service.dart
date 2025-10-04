import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/cache/cache.dart';

class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static final DateTime _defaultExpiry = DateTime.now().add(
    const Duration(hours: 24),
  );

  static Box<CacheEntry>? _cacheBox;
  static Box<CacheMetadata>? _metadataBox;

  // Cache keys for different data types
  static const String komunitasArtikelKey = 'komunitas_artikel';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CacheMetadataAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CacheEntryAdapter());
      }

      // Open boxes
      _cacheBox = await Hive.openBox<CacheEntry>(_cacheBoxName);
      _metadataBox = await Hive.openBox<CacheMetadata>(_metadataBoxName);

      logger.info('Generic cache service initialized successfully');
    } catch (e) {
      logger.severe('Failed to initialize cache service: $e');
      rethrow;
    }
  }

  // Generic method to cache any serializable data
  static Future<void> cacheData<T>({
    required String key,
    required T data,
    required String dataType,
    DateTime? customExpiry,
  }) async {
    try {
      if (_cacheBox == null) {
        logger.warning('Cache box not initialized');
        return;
      }

      final jsonData = jsonEncode(_toJson(data));
      final entry = CacheEntry(
        key: key,
        jsonData: jsonData,
        cachedAt: DateTime.now(),
        customExpiry: customExpiry,
        dataType: dataType,
      );

      await _cacheBox!.put(key, entry);
      logger.fine('Cached data for key: $key, type: $dataType');
    } catch (e) {
      logger.warning('Failed to cache data for key $key: $e');
    }
  }

  // Generic method to get cached data - DIPERBAIKI
  static T? getCachedData<T>({
    required String key,
    required T Function(dynamic) fromJson,
  }) {
    try {
      if (_cacheBox == null) {
        logger.warning('Cache box not initialized');
        return null;
      }

      final entry = _cacheBox!.get(key);
      if (entry == null) return null;

      // Check if cache is expired
      final expiry = entry.customExpiry != null
          ? entry.customExpiry!.difference(entry.cachedAt)
          : _defaultExpiry.difference(entry.cachedAt);
      final isExpired = DateTime.now().difference(entry.cachedAt) > expiry;

      if (isExpired) {
        logger.fine('Cache expired for key: $key');
        _cacheBox!.delete(key);
        _metadataBox?.delete(key);
        return null;
      }

      final data = jsonDecode(entry.jsonData);
      return fromJson(data);
    } catch (e) {
      logger.warning('Failed to get cached data for key $key: $e');
      return null;
    }
  }

  // Cache paginated data with metadata - DIPERBAIKI
  static Future<void> cachePaginatedData<T>({
    required String key,
    required List<T> data,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required String dataType,
    bool isLoadMore = false,
    DateTime? customExpiry,
  }) async {
    try {
      if (_cacheBox == null || _metadataBox == null) {
        logger.warning('Cache boxes not initialized');
        return;
      }

      List<T> finalData;

      if (isLoadMore && currentPage > 1) {
        // For load more, get existing data and append new data
        final existingData = getCachedData<List<T>>(
          key: key,
          fromJson: (jsonData) {
            if (jsonData is List) {
              // Return raw list, will be processed by specific service
              return jsonData as List<T>;
            }
            return <T>[];
          },
        );

        finalData = [...(existingData ?? <T>[]), ...data];
        logger.fine(
          'Load more: Combined ${existingData?.length ?? 0} existing + ${data.length} new = ${finalData.length} total',
        );
      } else {
        // For fresh load, use only new data
        finalData = data;
        logger.fine('Fresh load: ${data.length} items');
      }

      // Cache the combined data
      await cacheData(
        key: key,
        data: finalData,
        dataType: dataType,
        customExpiry: customExpiry,
      );

      // Cache metadata
      final metadata = CacheMetadata(
        lastFetch: DateTime.now(),
        totalPages: totalPages,
        currentPage: currentPage,
        totalItems: totalItems,
        cacheKey: key,
        customExpiry: customExpiry,
      );
      await _metadataBox!.put(key, metadata);

      logger.fine(
        'Cached paginated data: $key, page $currentPage, items: ${data.length}, total cached: ${finalData.length}',
      );
    } catch (e) {
      logger.warning('Failed to cache paginated data for key $key: $e');
    }
  }

  // Get cache metadata
  static CacheMetadata? getCacheMetadata(String key) {
    try {
      if (_metadataBox == null) {
        logger.warning('Metadata cache box not initialized');
        return null;
      }

      return _metadataBox!.get(key);
    } catch (e) {
      logger.warning('Failed to get cache metadata for key $key: $e');
      return null;
    }
  }

  // Check if cache is valid
  static bool isCacheValid(String key, {DateTime? customExpiry}) {
    try {
      if (_cacheBox == null) return false;

      final entry = _cacheBox!.get(key);
      if (entry == null) return false;

      final expiryDate = customExpiry ?? entry.customExpiry ?? _defaultExpiry;
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      logger.warning('Failed to check cache validity for key $key: $e');
      return false;
    }
  }

  // Check if cache exists - DIPERBAIKI
  static bool hasCachedData(String key) {
    try {
      if (_cacheBox == null) return false;
      final hasKey = _cacheBox!.containsKey(key);
      if (!hasKey) return false;

      // Check if expired
      final entry = _cacheBox!.get(key);
      if (entry == null) return false;

      final expiry = entry.customExpiry != null
          ? entry.customExpiry!.difference(entry.cachedAt)
          : _defaultExpiry.difference(entry.cachedAt);
      final isExpired = DateTime.now().difference(entry.cachedAt) > expiry;

      if (isExpired) {
        // Clean up expired cache
        _cacheBox!.delete(key);
        _metadataBox?.delete(key);
        return false;
      }

      return true;
    } catch (e) {
      logger.warning('Failed to check cached data for key $key: $e');
      return false;
    }
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    try {
      await _cacheBox?.delete(key);
      await _metadataBox?.delete(key);
      logger.fine('Cache cleared for key: $key');
    } catch (e) {
      logger.warning('Failed to clear cache for key $key: $e');
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      await _cacheBox?.clear();
      await _metadataBox?.clear();
      logger.fine('All cache cleared successfully');
    } catch (e) {
      logger.warning('Failed to clear all cache: $e');
    }
  }

  // Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      if (_cacheBox == null) return;

      final keysToDelete = <String>[];

      for (final entry in _cacheBox!.values) {
        final expiryDate = entry.customExpiry ?? _defaultExpiry;
        final isExpired = DateTime.now().isAfter(expiryDate);

        if (isExpired) {
          keysToDelete.add(entry.key);
        }
      }

      for (final key in keysToDelete) {
        await clearCache(key);
      }

      logger.fine('Cleared ${keysToDelete.length} expired cache entries');
    } catch (e) {
      logger.warning('Failed to clear expired cache: $e');
    }
  }

  // Get cache size info
  static Map<String, dynamic> getCacheInfo() {
    try {
      final cacheSize = _cacheBox?.length ?? 0;
      final metadataSize = _metadataBox?.length ?? 0;

      // Group by data type
      final typeCount = <String, int>{};
      if (_cacheBox != null) {
        for (final entry in _cacheBox!.values) {
          typeCount[entry.dataType] = (typeCount[entry.dataType] ?? 0) + 1;
        }
      }

      return {
        'total_entries': cacheSize,
        'metadata_entries': metadataSize,
        'types': typeCount,
        'last_cleanup': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      logger.warning('Failed to get cache info: $e');
      return {'total_entries': 0, 'metadata_entries': 0, 'types': {}};
    }
  }

  // Close boxes (call when app is closing)
  static Future<void> close() async {
    try {
      await _cacheBox?.close();
      await _metadataBox?.close();
      logger.fine('Cache boxes closed');
    } catch (e) {
      logger.warning('Failed to close cache boxes: $e');
    }
  }

  // Helper method to convert data to JSON
  static dynamic _toJson(dynamic data) {
    if (data is List) {
      return data.map((item) => _itemToJson(item)).toList();
    } else {
      return _itemToJson(data);
    }
  }

  static dynamic _itemToJson(dynamic item) {
    if (item == null) return null;

    // Check if item has toJson method
    try {
      if (item is Map) return item;
      return item.toJson();
    } catch (e) {
      // Fallback: try to serialize as basic types
      if (item is String || item is num || item is bool) {
        return item;
      }
      logger.warning('Cannot serialize item to JSON: $item');
      return item.toString();
    }
  }
}
