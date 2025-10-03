class KomunitasArtikel {
  final String id;
  final int userId;
  final String kategori;
  final String judul;
  final String excerpt;
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
}
