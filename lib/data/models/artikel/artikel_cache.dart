import 'package:hive/hive.dart';
import 'package:test_flutter/core/constants/hive_type_id.dart';
import 'package:test_flutter/data/models/artikel/artikel.dart';
import 'package:test_flutter/data/models/artikel/kategori_artikel_cache.dart';

part 'artikel_cache.g.dart';

@HiveType(typeId: HiveTypeId.artikel)
class ArtikelCache extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int kategoriId;

  @HiveField(2)
  String judul;

  @HiveField(3)
  String cover;

  @HiveField(4)
  String tipe;

  @HiveField(5)
  String? videoUrl;

  @HiveField(6)
  List<String> daftarGambar;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  String excerpt;

  @HiveField(10)
  String penulis;

  @HiveField(11)
  KategoriArtikelCache kategori;

  @HiveField(12)
  DateTime cachedAt;

  ArtikelCache({
    required this.id,
    required this.kategoriId,
    required this.judul,
    required this.cover,
    required this.tipe,
    this.videoUrl,
    required this.daftarGambar,
    required this.createdAt,
    required this.updatedAt,
    required this.excerpt,
    required this.penulis,
    required this.kategori,
    required this.cachedAt,
  });

  factory ArtikelCache.fromArtikel(Artikel a) {
    return ArtikelCache(
      id: a.id,
      kategoriId: a.kategoriId,
      judul: a.judul,
      cover: a.cover,
      tipe: a.tipe,
      videoUrl: a.videoUrl,
      daftarGambar: a.daftarGambar,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
      excerpt: a.excerpt,
      penulis: a.penulis,
      kategori: KategoriArtikelCache.fromKategoriArtikel(a.kategori),
      cachedAt: DateTime.now(),
    );
  }

  Artikel toArtikel() {
    return Artikel(
      id: id,
      kategoriId: kategoriId,
      judul: judul,
      cover: cover,
      tipe: tipe,
      videoUrl: videoUrl,
      daftarGambar: daftarGambar,
      createdAt: createdAt,
      updatedAt: updatedAt,
      excerpt: excerpt,
      penulis: penulis,
      kategori: kategori.toKategoriArtikel(),
    );
  }
}
