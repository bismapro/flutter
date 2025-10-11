import 'package:test_flutter/core/utils/format_helper.dart';
import 'package:test_flutter/data/models/artikel/kategori_artikel.dart';

class KomunitasArtikel {
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

  KomunitasArtikel({
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
  });

  factory KomunitasArtikel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is String) return int.tryParse(value) ?? 0;
      return value as int;
    }

    return KomunitasArtikel(
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
}

class KomunitasKomentar {
  final int id;
  final int artikelId;
  final int? userId;
  final String content;
  final bool isAnonymous;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  KomunitasKomentar({
    required this.id,
    required this.artikelId,
    this.userId,
    required this.content,
    required this.isAnonymous,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KomunitasKomentar.fromJson(Map<String, dynamic> json) {
    return KomunitasKomentar(
      id: json['id'] ?? 0,
      artikelId: json['artikel_id'] ?? 0,
      userId: json['user_id'],
      content: json['content'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      authorName: json['author_name'] ?? 'Unknown',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artikel_id': artikelId,
      'user_id': userId,
      'content': content,
      'is_anonymous': isAnonymous,
      'author_name': authorName,
      'created_at': FormatHelper.getFormattedDate(createdAt),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
