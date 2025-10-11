import 'package:test_flutter/data/models/artikel/kategori_artikel.dart';

class KomunitasPostingan {
  final int id;
  final int userId;
  final int kategoriId;
  final String judul;
  final String cover;
  final List<String> daftarGambar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String excerpt;
  final String penulis;
  final KategoriArtikel kategori;
  final int totalLikes;
  final int totalKomentar;
  final List<Komentar>? komentars;

  KomunitasPostingan({
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
    required this.penulis,
    required this.kategori,
    this.komentars,
  });

  factory KomunitasPostingan.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is String) return int.tryParse(value) ?? 0;
      return value as int;
    }

    return KomunitasPostingan(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      kategoriId: parseInt(json['kategori_id']),
      judul: json['judul'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      daftarGambar:
          (json['daftar_gambar'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalLikes: parseInt(json['total_likes']),
      totalKomentar: parseInt(json['total_komentar']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      penulis: json['penulis'] as String? ?? 'Unknown',
      kategori: KategoriArtikel.fromJson(
        json['kategori'] as Map<String, dynamic>,
      ),
      komentars: (json['komentars'] as List<dynamic>?)
          ?.map((e) => Komentar.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kategori_id': kategoriId,
      'judul': judul,
      'excerpt': excerpt,
      'cover': cover,
      'daftar_gambar': daftarGambar,
      'total_likes': totalLikes,
      'total_komentar': totalKomentar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'penulis': penulis,
      'kategori': kategori.toJson(),
    };
  }

  KomunitasPostingan? copyWith({required List<Komentar> komentars}) {
    return KomunitasPostingan(
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
      kategori: kategori,
      komentars: komentars,
    );
  }
}

class Komentar {
  final int id;
  final int postinganId;
  final int userId;
  final String komentar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String penulis;

  Komentar({
    required this.id,
    required this.postinganId,
    required this.userId,
    required this.komentar,
    required this.createdAt,
    required this.updatedAt,
    required this.penulis,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is String) return int.tryParse(value) ?? 0;
      return value as int;
    }

    return Komentar(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      postinganId: parseInt(json['postingan_id']),
      komentar: json['komentar'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      penulis: json['penulis'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'postingan_id': postinganId,
      'komentar': komentar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'penulis': penulis,
    };
  }
}
