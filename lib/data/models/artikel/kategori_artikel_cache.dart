import 'package:hive/hive.dart';
import 'package:test_flutter/data/models/artikel/kategori_artikel.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';

part 'kategori_artikel_cache.g.dart';

@HiveType(typeId: HiveTypeId.kategoriArtikel)
class KategoriArtikelCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String icon;

  @HiveField(3)
  DateTime cachedAt;

  KategoriArtikelCache({
    required this.id,
    required this.nama,
    required this.icon,
    required this.cachedAt,
  });

  factory KategoriArtikelCache.fromKategoriArtikel(KategoriArtikel k) {
    return KategoriArtikelCache(
      id: k.id,
      nama: k.nama,
      icon: k.icon,
      cachedAt: DateTime.now(),
    );
  }

  KategoriArtikel toKategoriArtikel() {
    return KategoriArtikel(id: id, nama: nama, icon: icon);
  }
}
