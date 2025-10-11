import 'package:test_flutter/data/models/artikel/kategori_artikel.dart';

class Artikel {
  final int id;
  final int kategoriId;
  final String judul;
  final String cover;
  final String tipe;
  final String? videoUrl;
  final List<String> daftarGambar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String excerpt;
  final String penulis;
  final KategoriArtikel kategori;

  Artikel({
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
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] as int,
      kategoriId: json['kategori_id'] as int,
      judul: json['judul'] as String,
      cover: json['cover'] as String,
      tipe: json['tipe'] as String,
      videoUrl: json['video_url'] as String?,
      daftarGambar:
          (json['daftar_gambar'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      excerpt: json['excerpt'] as String,
      penulis: json['penulis'] as String,
      kategori: KategoriArtikel.fromJson(
        json['kategori'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori_id': kategoriId,
      'judul': judul,
      'cover': cover,
      'tipe': tipe,
      'video_url': videoUrl,
      'daftar_gambar': daftarGambar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'excerpt': excerpt,
      'penulis': penulis,
      'kategori': kategori.toJson(),
    };
  }
}
