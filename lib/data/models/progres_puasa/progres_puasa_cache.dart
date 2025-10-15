import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:test_flutter/core/constants/hive_type_id.dart';
import 'package:test_flutter/data/models/progres_puasa/progres_puasa.dart';

part 'progres_puasa_cache.g.dart';

/// ===============================================================
///  ENTRI PUASA: WAJIB  (typeId 18, sesuai HiveTypeId.progresPuasaWajib)
/// ===============================================================
@HiveType(typeId: HiveTypeId.progresPuasaWajib)
class ProgresPuasaWajibCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  /// contoh: "wajib" / "ramadhan"
  @HiveField(2)
  String jenis;

  /// Tahun Hijriah (mis. 1447)
  @HiveField(3)
  int tahunHijriah;

  /// Non-null di cache; fallback ke now jika null di model
  @HiveField(4)
  DateTime createdAt;

  /// Non-null di cache; fallback ke createdAt jika null di model
  @HiveField(5)
  DateTime updatedAt;

  /// Tanggal saat data dicache di device
  @HiveField(6)
  DateTime cachedAt;

  ProgresPuasaWajibCache({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.tahunHijriah,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory ProgresPuasaWajibCache.fromModel(ProgresPuasa model) {
    final created = model.createdAt ?? DateTime.now();
    final updated = model.updatedAt ?? created;
    return ProgresPuasaWajibCache(
      id: model.id,
      userId: model.userId,
      jenis: model.jenis,
      tahunHijriah: model.tahunHijriah,
      createdAt: created,
      updatedAt: updated,
      cachedAt: DateTime.now(),
    );
  }

  ProgresPuasa toModel() {
    return ProgresPuasa(
      id: id,
      userId: userId,
      jenis: jenis,
      tahunHijriah: tahunHijriah,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// ===============================================================
///  ENTRI PUASA: SUNNAH (typeId 14, sesuai HiveTypeId.progresPuasaSunnah)
/// ===============================================================
@HiveType(typeId: HiveTypeId.progresPuasaSunnah)
class ProgresPuasaSunnahCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  /// contoh: "sunnah" / "senin-kamis" / "ayyamul-bidh" / "arafah" dll.
  @HiveField(2)
  String jenis;

  /// Tahun Hijriah (mis. 1447)
  @HiveField(3)
  int tahunHijriah;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  DateTime cachedAt;

  ProgresPuasaSunnahCache({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.tahunHijriah,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  factory ProgresPuasaSunnahCache.fromModel(ProgresPuasa model) {
    final created = model.createdAt ?? DateTime.now();
    final updated = model.updatedAt ?? created;
    return ProgresPuasaSunnahCache(
      id: model.id,
      userId: model.userId,
      jenis: model.jenis,
      tahunHijriah: model.tahunHijriah,
      createdAt: created,
      updatedAt: updated,
      cachedAt: DateTime.now(),
    );
  }

  ProgresPuasa toModel() {
    return ProgresPuasa(
      id: id,
      userId: userId,
      jenis: jenis,
      tahunHijriah: tahunHijriah,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// =======================================================================
///  AGREGAT: PROGRES PUASA WAJIB TAHUN INI (typeId 20)
///  Model asli: total + detail: List<Map<String, dynamic>>
///  Di cache: simpan detail sebagai JSON string (detailJson)
/// =======================================================================
@HiveType(typeId: HiveTypeId.progresPuasaWajibTahunIni)
class ProgresPuasaWajibTahunIniCache extends HiveObject {
  @HiveField(0)
  int total;

  @HiveField(1)
  String detailJson;

  @HiveField(2)
  DateTime cachedAt;

  ProgresPuasaWajibTahunIniCache({
    required this.total,
    required this.detailJson,
    required this.cachedAt,
  });

  factory ProgresPuasaWajibTahunIniCache.fromModel(
    ProgresPuasaWajibTahunIni model,
  ) {
    final jsonStr = jsonEncode(model.detail);
    return ProgresPuasaWajibTahunIniCache(
      total: model.total,
      detailJson: jsonStr,
      cachedAt: DateTime.now(),
    );
  }

  ProgresPuasaWajibTahunIni toModel() {
    final decoded = jsonDecode(detailJson);
    return ProgresPuasaWajibTahunIni(
      total: total,
      detail: Map<String, dynamic>.from(decoded),
    );
  }
}

/// =======================================================================
///  RIWAYAT: PUASA WAJIB (typeId 21)
///  Model asli: tahun + data: List<ProgresPuasa>
///  Di cache: tahun + data: List<ProgresPuasaWajibCache>
/// =======================================================================
@HiveType(typeId: HiveTypeId.riwayatPuasaWajib)
class RiwayatPuasaWajibCache extends HiveObject {
  @HiveField(0)
  int tahun;

  @HiveField(1)
  List<ProgresPuasaWajibCache> data;

  @HiveField(2)
  DateTime cachedAt;

  RiwayatPuasaWajibCache({
    required this.tahun,
    required this.data,
    required this.cachedAt,
  });

  factory RiwayatPuasaWajibCache.fromModel(RiwayatPuasaWajib model) {
    return RiwayatPuasaWajibCache(
      tahun: model.tahun,
      data: model.data.map(ProgresPuasaWajibCache.fromModel).toList(),
      cachedAt: DateTime.now(),
    );
  }

  RiwayatPuasaWajib toModel() {
    return RiwayatPuasaWajib(
      tahun: tahun,
      data: data.map((e) => e.toModel()).toList(),
    );
  }
}

/// =======================================================================
///  AGREGAT: PROGRES PUASA SUNNAH TAHUN INI (typeId 22)
///  Model asli: total + detail: List<ProgresPuasa>
///  Di cache: total + detail: List<ProgresPuasaSunnahCache>
/// =======================================================================
@HiveType(typeId: HiveTypeId.progresPuasaSunnahTahunIni)
class ProgresPuasaSunnahTahunIniCache extends HiveObject {
  @HiveField(0)
  int total;

  @HiveField(1)
  List<ProgresPuasaSunnahCache> detail;

  @HiveField(2)
  DateTime cachedAt;

  ProgresPuasaSunnahTahunIniCache({
    required this.total,
    required this.detail,
    required this.cachedAt,
  });

  factory ProgresPuasaSunnahTahunIniCache.fromModel(
    ProgresPuasaSunnahTahunIni model,
  ) {
    return ProgresPuasaSunnahTahunIniCache(
      total: model.total,
      detail: model.detail.map(ProgresPuasaSunnahCache.fromModel).toList(),
      cachedAt: DateTime.now(),
    );
  }

  ProgresPuasaSunnahTahunIni toModel() {
    return ProgresPuasaSunnahTahunIni(
      total: total,
      detail: detail.map((e) => e.toModel()).toList(),
    );
  }
}

/// =======================================================================
///  RIWAYAT: PUASA SUNNAH (typeId 23)
///  Model asli: total + detail: List<ProgresPuasa>
///  Di cache: total + detail: List<ProgresPuasaSunnahCache>
/// =======================================================================
@HiveType(typeId: HiveTypeId.riwayatPuasaSunnah)
class RiwayatPuasaSunnahCache extends HiveObject {
  @HiveField(0)
  int total;

  @HiveField(1)
  List<ProgresPuasaSunnahCache> detail;

  @HiveField(2)
  DateTime cachedAt;

  RiwayatPuasaSunnahCache({
    required this.total,
    required this.detail,
    required this.cachedAt,
  });

  factory RiwayatPuasaSunnahCache.fromModel(RiwayatPuasaSunnah model) {
    return RiwayatPuasaSunnahCache(
      total: model.total,
      detail: model.detail.map(ProgresPuasaSunnahCache.fromModel).toList(),
      cachedAt: DateTime.now(),
    );
  }

  RiwayatPuasaSunnah toModel() {
    return RiwayatPuasaSunnah(
      total: total,
      detail: detail.map((e) => e.toModel()).toList(),
    );
  }
}
