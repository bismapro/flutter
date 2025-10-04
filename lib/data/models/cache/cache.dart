import 'package:hive/hive.dart';

part 'cache.g.dart';

@HiveType(typeId: 0)
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

@HiveType(typeId: 1)
class CacheEntry extends HiveObject {
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
