import 'package:hive/hive.dart';
import 'package:test_flutter/core/constants/hive_type_id.dart';
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

@HiveType(typeId: HiveTypeId.statistikSholatWajib)
class StatistikSholatWajibCache extends HiveObject {
  @HiveField(0)
  bool subuh;
  @HiveField(1)
  bool dzuhur;
  @HiveField(2)
  bool ashar;
  @HiveField(3)
  bool maghrib;
  @HiveField(4)
  bool isya;
  @HiveField(5)
  DateTime cachedAt;

  StatistikSholatWajibCache({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.cachedAt,
  });

  factory StatistikSholatWajibCache.fromStatistikSholatWajib(
    StatistikSholatWajib model,
  ) {
    return StatistikSholatWajibCache(
      subuh: model.subuh,
      dzuhur: model.dzuhur,
      ashar: model.ashar,
      maghrib: model.maghrib,
      isya: model.isya,
      cachedAt: DateTime.now(),
    );
  }

  StatistikSholatWajib toStatistikSholatWajib() {
    return StatistikSholatWajib(
      subuh: subuh,
      dzuhur: dzuhur,
      ashar: ashar,
      maghrib: maghrib,
      isya: isya,
    );
  }
}

@HiveType(typeId: HiveTypeId.progresSholatWajib)
class ProgresSholatWajibCache extends HiveObject {
  @HiveField(0)
  int total;

  @HiveField(1)
  StatistikSholatWajibCache statistik;

  @HiveField(2)
  List<ProgresSholatCache> detail;

  @HiveField(3)
  DateTime cachedAt;

  ProgresSholatWajibCache({
    required this.total,
    required this.statistik,
    required this.detail,
    required this.cachedAt,
  });

  factory ProgresSholatWajibCache.fromProgresSholatWajib(
    ProgresSholatWajib model,
  ) {
    return ProgresSholatWajibCache(
      total: model.total,
      statistik: StatistikSholatWajibCache.fromStatistikSholatWajib(
        model.statistik,
      ),
      detail: model.detail
          .map((e) => ProgresSholatCache.fromProgresSholat(e))
          .toList(),
      cachedAt: DateTime.now(),
    );
  }

  ProgresSholatWajib toProgresSholatWajib() {
    return ProgresSholatWajib(
      total: total,
      statistik: statistik.toStatistikSholatWajib(),
      detail: detail.map((e) => e.toProgresSholat()).toList(),
    );
  }
}

@HiveType(typeId: HiveTypeId.statistikSholatSunnah)
class StatistikSholatSunnahCache extends HiveObject {
  @HiveField(0)
  bool tahajud;
  @HiveField(1)
  bool witir;
  @HiveField(2)
  bool dhuha;
  @HiveField(3)
  bool qabliyahSubuh;
  @HiveField(4)
  bool qabliyahDzuhur;
  @HiveField(5)
  bool baDiyahDzuhur;
  @HiveField(6)
  bool qabliyahAshar;
  @HiveField(7)
  bool baDiyahMaghrib;
  @HiveField(8)
  bool qabliyahIsya;
  @HiveField(9)
  bool baDiyahIsya;
  @HiveField(10)
  DateTime cachedAt;

  // Constructor and conversion methods...
  StatistikSholatSunnahCache({
    required this.tahajud,
    required this.witir,
    required this.dhuha,
    required this.qabliyahSubuh,
    required this.qabliyahDzuhur,
    required this.baDiyahDzuhur,
    required this.qabliyahAshar,
    required this.baDiyahMaghrib,
    required this.qabliyahIsya,
    required this.baDiyahIsya,
    required this.cachedAt,
  });

  factory StatistikSholatSunnahCache.fromStatistikSholatSunnah(
    StatistikSholatSunnah model,
  ) {
    return StatistikSholatSunnahCache(
      tahajud: model.tahajud,
      witir: model.witir,
      dhuha: model.dhuha,
      qabliyahSubuh: model.qabliyahSubuh,
      qabliyahDzuhur: model.qabliyahDzuhur,
      baDiyahDzuhur: model.baDiyahDzuhur,
      qabliyahAshar: model.qabliyahAshar,
      baDiyahMaghrib: model.baDiyahMaghrib,
      qabliyahIsya: model.qabliyahIsya,
      baDiyahIsya: model.baDiyahIsya,
      cachedAt: DateTime.now(),
    );
  }

  StatistikSholatSunnah toStatistikSholatSunnah() {
    return StatistikSholatSunnah(
      tahajud: tahajud,
      witir: witir,
      dhuha: dhuha,
      qabliyahSubuh: qabliyahSubuh,
      qabliyahDzuhur: qabliyahDzuhur,
      baDiyahDzuhur: baDiyahDzuhur,
      qabliyahAshar: qabliyahAshar,
      baDiyahMaghrib: baDiyahMaghrib,
      qabliyahIsya: qabliyahIsya,
      baDiyahIsya: baDiyahIsya,
    );
  }
}

@HiveType(typeId: HiveTypeId.progresSholatSunnah)
class ProgresSholatSunnahCache extends HiveObject {
  @HiveField(0)
  int total;

  @HiveField(1)
  StatistikSholatSunnahCache statistik;

  @HiveField(2)
  List<ProgresSholatCache> detail;

  @HiveField(3)
  DateTime cachedAt;

  ProgresSholatSunnahCache({
    required this.total,
    required this.statistik,
    required this.detail,
    required this.cachedAt,
  });

  factory ProgresSholatSunnahCache.fromProgresSholatSunnah(
    ProgresSholatSunnah model,
  ) {
    return ProgresSholatSunnahCache(
      total: model.total,
      statistik: StatistikSholatSunnahCache.fromStatistikSholatSunnah(
        model.statistik,
      ),
      detail: model.detail
          .map((e) => ProgresSholatCache.fromProgresSholat(e))
          .toList(),
      cachedAt: DateTime.now(),
    );
  }

  ProgresSholatSunnah toProgresSholatSunnah() {
    return ProgresSholatSunnah(
      total: total,
      statistik: statistik.toStatistikSholatSunnah(),
      detail: detail.map((e) => e.toProgresSholat()).toList(),
    );
  }
}

@HiveType(typeId: HiveTypeId.riwayatProgres)
class RiwayatProgresCache extends HiveObject {
  @HiveField(0)
  Map<String, List<ProgresSholatCache>> data;

  @HiveField(1)
  DateTime cachedAt;

  RiwayatProgresCache({required this.data, required this.cachedAt});

  factory RiwayatProgresCache.fromRiwayatProgres(RiwayatProgres model) {
    final cachedData = model.data.map((key, value) {
      final listCache = value
          .map((e) => ProgresSholatCache.fromProgresSholat(e))
          .toList();
      return MapEntry(key, listCache);
    });

    return RiwayatProgresCache(data: cachedData, cachedAt: DateTime.now());
  }

  RiwayatProgres toRiwayatProgres() {
    final modelData = data.map((key, value) {
      final listModel = value.map((e) => e.toProgresSholat()).toList();
      return MapEntry(key, listModel);
    });

    return RiwayatProgres(data: modelData);
  }
}
