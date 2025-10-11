import 'package:hive/hive.dart';
import 'package:test_flutter/core/utils/hive_type_id.dart';
import 'package:test_flutter/data/models/artikel/kategori_artikel_cache.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';

part 'komunitas_cache.g.dart';

@HiveType(typeId: HiveTypeId.komunitas)
class KomunitasArtikelCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  int kategoriId;

  @HiveField(3)
  String judul;

  @HiveField(4)
  String excerpt;

  @HiveField(5)
  String cover;

  @HiveField(6)
  List<String> daftarGambar;

  @HiveField(7)
  int totalLikes;

  @HiveField(8)
  int totalKomentar;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  DateTime cachedAt;

  @HiveField(12)
  String penulis;

  @HiveField(13)
  KategoriArtikelCache kategori;

  KomunitasArtikelCache({
    required this.id,
    required this.userId,
    required this.kategoriId,
    required this.judul,
    required this.excerpt,
    required this.cover,
    required this.daftarGambar,
    required this.totalLikes,
    required this.totalKomentar,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
    required this.penulis,
    required this.kategori,
  });

  factory KomunitasArtikelCache.fromKomunitasArtikel(KomunitasArtikel artikel) {
    return KomunitasArtikelCache(
      id: artikel.id,
      userId: artikel.userId,
      kategoriId: artikel.kategoriId,
      judul: artikel.judul,
      excerpt: artikel.excerpt,
      cover: artikel.cover,
      daftarGambar: artikel.daftarGambar,
      totalLikes: artikel.totalLikes,
      totalKomentar: artikel.totalKomentar,
      createdAt: artikel.createdAt,
      updatedAt: artikel.updatedAt,
      cachedAt: DateTime.now(),
      penulis: artikel.penulis,
      kategori: KategoriArtikelCache.fromKategoriArtikel(artikel.kategori),
    );
  }

  KomunitasArtikel toKomunitasArtikel() {
    return KomunitasArtikel(
      id: id,
      userId: userId,
      kategoriId: kategoriId,
      judul: judul,
      excerpt: excerpt,
      cover: cover,
      daftarGambar: daftarGambar,
      totalLikes: totalLikes,
      totalKomentar: totalKomentar,
      createdAt: createdAt,
      updatedAt: updatedAt,
      penulis: penulis,
      kategori: kategori.toKategoriArtikel(),
    );
  }
}
