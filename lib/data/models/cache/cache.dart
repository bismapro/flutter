import 'package:hive/hive.dart';
import 'package:test_flutter/core/constants/hive_type_id.dart';

part 'cache.g.dart';

@HiveType(typeId: HiveTypeId.cacheMetadata)
class CacheMetadata extends HiveObject {
  @HiveField(0)
  DateTime lastFetch;

  @HiveField(1)
  int totalPages;

  @HiveField(2)
  int currentPage;

  @HiveField(3)
  int totalItems;

  @HiveField(4)
  String cacheKey;

  @HiveField(5)
  DateTime? customExpiry;

  CacheMetadata({
    required this.lastFetch,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
    required this.cacheKey,
    this.customExpiry,
  });
}

@HiveType(typeId: HiveTypeId.cacheEntry)
class CacheEntry extends HiveObject {
  @override
  @HiveField(0)
  String key;

  @HiveField(1)
  String jsonData;

  @HiveField(2)
  DateTime cachedAt;

  @HiveField(3)
  DateTime? customExpiry;

  @HiveField(4)
  String dataType;

  CacheEntry({
    required this.key,
    required this.jsonData,
    required this.cachedAt,
    this.customExpiry,
    required this.dataType,
  });
}
