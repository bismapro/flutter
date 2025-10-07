import 'package:test_flutter/core/utils/format_helper.dart';

class KomunitasArtikel {
  final String id;
  final int userId;
  final String kategori;
  final String judul;
  final String excerpt;
  final String? isi;
  final List<String> gambar;
  final int isAnonymous;
  final int jumlahLike;
  final int jumlahKomentar;
  final DateTime createdAt;
  final DateTime updatedAt;

  KomunitasArtikel({
    required this.id,
    required this.userId,
    required this.kategori,
    required this.judul,
    required this.excerpt,
    required this.gambar,
    required this.isAnonymous,
    required this.jumlahLike,
    required this.jumlahKomentar,
    required this.createdAt,
    required this.updatedAt,
    required this.isi,
  });

  factory KomunitasArtikel.fromJson(Map<String, dynamic> m) {
    return KomunitasArtikel(
      id: m['id'] ?? '',
      userId: m['user_id'] is String
          ? int.parse(m['user_id'])
          : m['user_id'] ?? 0,
      kategori: m['kategori'] ?? '',
      judul: m['judul'] ?? '',
      excerpt: m['excerpt'] ?? '',
      isi: m['isi'] ?? '',
      gambar: List<String>.from(m['gambar'] ?? []),
      isAnonymous: m['is_anonymous'] is String
          ? int.parse(m['is_anonymous'])
          : m['is_anonymous'] ?? 0,
      jumlahLike: m['jumlah_like'] is String
          ? int.parse(m['jumlah_like'])
          : m['jumlah_like'] ?? 0,
      jumlahKomentar: m['jumlah_komentar'] is String
          ? int.parse(m['jumlah_komentar'])
          : m['jumlah_komentar'] ?? 0,
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(m['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kategori': kategori,
      'judul': judul,
      'excerpt': excerpt,
      'isi': isi,
      'gambar': gambar,
      'is_anonymous': isAnonymous,
      'jumlah_like': jumlahLike,
      'jumlah_komentar': jumlahKomentar,
      'created_at': FormatHelper.getFormattedDate(createdAt),
      'updated_at': updatedAt.toIso8601String(),
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
