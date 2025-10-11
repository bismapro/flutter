import 'package:hive/hive.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

part 'sholat_cache.g.dart';

@HiveType(typeId: HiveTypeId.sholat)
class SholatCache extends HiveObject {
  @HiveField(0)
  String tanggal;

  @HiveField(1)
  SholatWajibCache wajib;

  @HiveField(2)
  SholatSunnahCache sunnah;

  @HiveField(3)
  DateTime cachedAt;

  SholatCache({
    required this.tanggal,
    required this.wajib,
    required this.sunnah,
    required this.cachedAt,
  });

  factory SholatCache.fromSholat(Sholat s) {
    return SholatCache(
      tanggal: s.tanggal,
      wajib: SholatWajibCache.fromSholatWajib(s.wajib),
      sunnah: SholatSunnahCache.fromSholatSunnah(s.sunnah),
      cachedAt: DateTime.now(),
    );
  }

  Sholat toSholat() {
    return Sholat(
      tanggal: tanggal,
      wajib: wajib.toSholatWajib(),
      sunnah: sunnah.toSholatSunnah(),
    );
  }
}

@HiveType(typeId: HiveTypeId.sholatWajib)
class SholatWajibCache extends HiveObject {
  @HiveField(0)
  String shubuh;

  @HiveField(1)
  String dzuhur;

  @HiveField(2)
  String ashar;

  @HiveField(3)
  String maghrib;

  @HiveField(4)
  String isya;

  SholatWajibCache({
    required this.shubuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory SholatWajibCache.fromSholatWajib(SholatWajib s) {
    return SholatWajibCache(
      shubuh: s.shubuh,
      dzuhur: s.dzuhur,
      ashar: s.ashar,
      maghrib: s.maghrib,
      isya: s.isya,
    );
  }

  SholatWajib toSholatWajib() {
    return SholatWajib(
      shubuh: shubuh,
      dzuhur: dzuhur,
      ashar: ashar,
      maghrib: maghrib,
      isya: isya,
    );
  }
}

@HiveType(typeId: HiveTypeId.sholatSunnah)
class SholatSunnahCache extends HiveObject {
  @HiveField(0)
  String tahajud;

  @HiveField(1)
  String witir;

  @HiveField(2)
  String dhuha;

  @HiveField(3)
  String qabliyahSubuh;

  @HiveField(4)
  String qabliyahDzuhur;

  @HiveField(5)
  String baDiyahDzuhur;

  @HiveField(6)
  String qabliyahAshar;

  @HiveField(7)
  String baDiyahMaghrib;

  @HiveField(8)
  String qabliyahIsya;

  @HiveField(9)
  String baDiyahIsya;

  SholatSunnahCache({
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
  });

  factory SholatSunnahCache.fromSholatSunnah(SholatSunnah s) {
    return SholatSunnahCache(
      tahajud: s.tahajud,
      witir: s.witir,
      dhuha: s.dhuha,
      qabliyahSubuh: s.qabliyahSubuh,
      qabliyahDzuhur: s.qabliyahDzuhur,
      baDiyahDzuhur: s.baDiyahDzuhur,
      qabliyahAshar: s.qabliyahAshar,
      baDiyahMaghrib: s.baDiyahMaghrib,
      qabliyahIsya: s.qabliyahIsya,
      baDiyahIsya: s.baDiyahIsya,
    );
  }

  SholatSunnah toSholatSunnah() {
    return SholatSunnah(
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
