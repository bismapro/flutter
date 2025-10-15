import 'package:hijri_date_time/hijri_date_time.dart';
import 'package:intl/intl.dart';

class FormatHelper {
  /// Mengubah DateTime menjadi format "waktu yang lalu" (Contoh: 5 menit yang lalu).
  /// Lebih user-friendly untuk menampilkan durasi singkat.
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 2) {
      // Jika lebih dari 2 hari, tampilkan tanggal lengkap
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } else if (difference.inDays >= 1) {
      return 'Kemarin';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Memformat angka (integer) menjadi format mata uang Rupiah.
  /// Contoh: 50000 -> "Rp50.000"
  static String formatCurrency(int amount, {String locale = 'id_ID'}) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: 'Rp', // Simbol Rupiah
      decimalDigits: 0, // Tanpa angka desimal
    );
    return format.format(amount);
  }

  /// Mendapatkan nama hari dari sebuah tanggal dalam Bahasa Indonesia.
  /// Contoh: "Selasa"
  static String getDayName(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('EEEE', locale).format(date);
  }

  /// Memformat tanggal menjadi format lengkap dalam Bahasa Indonesia.
  /// Contoh: "14 Oktober 2025"
  static String getFullDate(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('d MMMM yyyy', locale).format(date);
  }

  /// Mengonversi tanggal Masehi ke format tanggal Hijriah lengkap.
  /// Contoh: "14 Rabiul Awal 1447 H"
  static String getHijriDate(DateTime date) {
    try {
      // Konversi dari Gregorian ke Hijriah
      final hijriDate = HijriDateTime.fromGregorian(date);

      // Daftar nama bulan Hijriah
      const hijriMonths = [
        'Muharram',
        'Safar',
        'Rabiul Awal',
        'Rabiul Akhir',
        'Jumadil Awal',
        'Jumadil Akhir',
        'Rajab',
        'Syaban',
        'Ramadhan',
        'Syawal',
        'Zulkaidah',
        'Zulhijjah',
      ];

      // Ambil nama bulan dari list (index bulan - 1)
      final monthName = hijriMonths[hijriDate.month - 1];

      // Format hasil akhir seperti "9 Muharram 1446 H"
      return '${hijriDate.day} $monthName ${hijriDate.year} H';
    } catch (e) {
      return 'Tanggal Hijriah';
    }
  }
}
