import 'package:hive/hive.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';
import 'package:test_flutter/data/models/sedekah/sedekah.dart';

part 'sedekah_cache.g.dart';

@HiveType(typeId: HiveTypeId.sedekah)
class SedekahCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String jenisSedekah;

  @HiveField(3)
  DateTime tanggal;

  @HiveField(4)
  int jumlah;

  @HiveField(5)
  String? keterangan;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  DateTime cachedAt;

  SedekahCache({
    required this.id,
    required this.userId,
    required this.jenisSedekah,
    required this.tanggal,
    required this.jumlah,
    required this.keterangan,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory SedekahCache.fromSedekah(Sedekah s) {
    return SedekahCache(
      id: s.id,
      userId: s.userId,
      jenisSedekah: s.jenisSedekah,
      tanggal: s.tanggal,
      jumlah: s.jumlah,
      keterangan: s.keterangan,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  Sedekah toSedekah() {
    return Sedekah(
      id: id,
      userId: userId,
      jenisSedekah: jenisSedekah,
      tanggal: tanggal,
      jumlah: jumlah,
      keterangan: keterangan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@HiveType(typeId: HiveTypeId.statistikSedekah)
class StatistikSedekahCache extends HiveObject {
  @HiveField(0)
  int totalHariIni;

  @HiveField(1)
  int totalBulanIni;

  /// Simpan riwayat sebagai list dari SedekahCache untuk memudahkan reconvert
  @HiveField(2)
  List<SedekahCache> riwayat;

  @HiveField(3)
  DateTime cachedAt;

  StatistikSedekahCache({
    required this.totalHariIni,
    required this.totalBulanIni,
    required this.riwayat,
    required this.cachedAt,
  });

  factory StatistikSedekahCache.fromStatistik(StatistikSedekah s) {
    return StatistikSedekahCache(
      totalHariIni: s.totalHariIni,
      totalBulanIni: s.totalBulanIni,
      riwayat: s.riwayat.map(SedekahCache.fromSedekah).toList(),
      cachedAt: DateTime.now(),
    );
  }

  StatistikSedekah toStatistik() {
    return StatistikSedekah(
      totalHariIni: totalHariIni,
      totalBulanIni: totalBulanIni,
      riwayat: riwayat.map((e) => e.toSedekah()).toList(),
    );
  }
}
