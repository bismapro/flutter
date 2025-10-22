import 'package:hijri/hijri_calendar.dart';
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

  static String getHijriDate(DateTime date) {
    try {
      HijriCalendar.setLocal('en');
      final h = HijriCalendar.fromDate(date);

      // Ambil nama bulan dari package, ubah ke lower case & hilangkan tanda petik
      final monthEn = h
          .getLongMonthName()
          .toLowerCase()
          .replaceAll("'", "")
          .trim();

      const monthMapId = {
        'muharram': 'Muharram',
        'safar': 'Safar',
        'rabi al-awwal': 'Rabiul Awal',
        'rabi al-thani': 'Rabiul Akhir',
        'jumada al-awwal': 'Jumadil Awal',
        'jumada al-thani': 'Jumadil Akhir',
        'rajab': 'Rajab',
        'shaaban': 'Syaban',
        'sha ban': 'Syaban',
        'ramadan': 'Ramadhan',
        'shawwal': 'Syawal',
        'dhu al-qidah': 'Zulkaidah',
        'dhu al-hijjah': 'Zulhijjah',
      };

      final monthId = monthMapId[monthEn] ?? h.getLongMonthName();
      return '${h.hDay} $monthId ${h.hYear} H';
    } catch (e) {
      return 'Tanggal Hijriah';
    }
  }
}
