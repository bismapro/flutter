import 'package:hive/hive.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';

part 'komunitas_cache.g.dart';

@HiveType(typeId: 0)
class KomunitasArtikelCache extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String kategori;

  @HiveField(3)
  String judul;

  @HiveField(4)
  String excerpt;

  @HiveField(5)
  String? isi;

  @HiveField(6)
  List<String> gambar;

  @HiveField(7)
  int isAnonymous;

  @HiveField(8)
  int jumlahLike;

  @HiveField(9)
  int jumlahKomentar;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  DateTime cachedAt;

  KomunitasArtikelCache({
    required this.id,
    required this.userId,
    required this.kategori,
    required this.judul,
    required this.excerpt,
    this.isi,
    required this.gambar,
    required this.isAnonymous,
    required this.jumlahLike,
    required this.jumlahKomentar,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
  });

  // Convert from KomunitasArtikel to cache model
  factory KomunitasArtikelCache.fromKomunitasArtikel(KomunitasArtikel artikel) {
    return KomunitasArtikelCache(
      id: artikel.id,
      userId: artikel.userId,
      kategori: artikel.kategori,
      judul: artikel.judul,
      excerpt: artikel.excerpt,
      isi: artikel.isi,
      gambar: artikel.gambar,
      isAnonymous: artikel.isAnonymous,
      jumlahLike: artikel.jumlahLike,
      jumlahKomentar: artikel.jumlahKomentar,
      createdAt: artikel.createdAt,
      updatedAt: artikel.updatedAt,
      cachedAt: DateTime.now(),
    );
  }

  // Convert to KomunitasArtikel
  KomunitasArtikel toKomunitasArtikel() {
    return KomunitasArtikel(
      id: id,
      userId: userId,
      kategori: kategori,
      judul: judul,
      excerpt: excerpt,
      isi: isi,
      gambar: gambar,
      isAnonymous: isAnonymous,
      jumlahLike: jumlahLike,
      jumlahKomentar: jumlahKomentar,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}