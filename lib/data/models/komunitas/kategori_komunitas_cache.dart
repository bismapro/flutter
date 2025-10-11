import 'package:hive/hive.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';
import 'package:test_flutter/data/models/komunitas/kategori_komunitas.dart';

part 'kategori_komunitas_cache.g.dart';

@HiveType(typeId: HiveTypeId.kategoriKomunitas)
class KategoriKomunitasCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String icon;

  @HiveField(3)
  DateTime cachedAt;

  KategoriKomunitasCache({
    required this.id,
    required this.nama,
    required this.icon,
    required this.cachedAt,
  });

  factory KategoriKomunitasCache.fromKategoriKomunitas(KategoriKomunitas k) {
    return KategoriKomunitasCache(
      id: k.id,
      nama: k.nama,
      icon: k.icon,
      cachedAt: DateTime.now(),
    );
  }

  KategoriKomunitas toKategoriKomunitas() {
    return KategoriKomunitas(id: id, nama: nama, icon: icon);
  }
}
