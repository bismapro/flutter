class CacheKeys {
  // Private constructor agar class ini tidak bisa di-instantiate (dibuat objeknya).
  CacheKeys._();

  // Komunitas
  static const String komunitasKategori = 'komunitas_kategori';
  static const String komunitasPostingan = 'komunitas_postingan';
  static String postinganDetail(String artikelId) =>
      'detail_postingan_$artikelId';
  static String komentarPostingan(String artikelId) =>
      'komentar_postingan_$artikelId';

  // Sedekah
  static const String sedekah = 'sedekah';

  // Artikel
  static const String artikelKategori = 'artikel_kategori';
  static const String artikelList = 'artikel';
  static String artikelDetail(int artikelId) => 'detail_artikel_$artikelId';

  // Home
  static const String homeJadwalSholat = 'home_jadwal_sholat';
  static const String homeLatestArticle = 'home_latest_article';
}
