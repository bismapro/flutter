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

  static const String sedekahStats = 'sedekah_stats';
  static const String detailCampaign = 'detail_campaign';

  static const String userProfile = 'user_profile';
  static const String userRiwayatDonasi = 'user_riwayat_donasi';

  // Tambahkan grup kunci lain di sini...
}
