import 'package:hive/hive.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';
import 'package:test_flutter/data/models/progres_sholat/progress_sholat.dart';

part 'progres_sholat_cache.g.dart';

@HiveType(typeId: HiveTypeId.progresSholat)
class ProgresSholatCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String jenis;

  @HiveField(3)
  String sholat;

  @HiveField(4)
  bool isOnTime;

  @HiveField(5)
  bool isJamaah;

  @HiveField(6)
  String lokasi;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  DateTime cachedAt;

  ProgresSholatCache({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.sholat,
    required this.isOnTime,
    required this.isJamaah,
    required this.lokasi,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory ProgresSholatCache.fromProgresSholat(ProgresSholat model) {
    return ProgresSholatCache(
      id: model.id,
      userId: model.userId,
      jenis: model.jenis,
      sholat: model.sholat,
      isOnTime: model.isOnTime,
      isJamaah: model.isJamaah,
      lokasi: model.lokasi,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  ProgresSholat toProgresSholat() {
    return ProgresSholat(
      id: id,
      userId: userId,
      jenis: jenis,
      sholat: sholat,
      isOnTime: isOnTime,
      isJamaah: isJamaah,
      lokasi: lokasi,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
