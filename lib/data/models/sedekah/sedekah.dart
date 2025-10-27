import 'package:test_flutter/core/utils/format_helper.dart';

class Sedekah {
  final int id;
  final int userId;
  final String jenisSedekah;

  /// Tanggal sedekah (yyyy-MM-dd dari API)
  final DateTime tanggal;
  final int jumlah;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sedekah({
    required this.id,
    required this.userId,
    required this.jenisSedekah,
    required this.tanggal,
    required this.jumlah,
    required this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sedekah.fromJson(Map<String, dynamic> m) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      // 'tanggal' bisa "2025-10-02" (tanpa waktu) → still parseable
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return Sedekah(
      id: toInt(m['id']),
      userId: toInt(m['user_id']),
      jenisSedekah: m['jenis_sedekah']?.toString() ?? '',
      tanggal: parseDate(m['tanggal']),
      jumlah: toInt(m['jumlah']),
      keterangan: m['keterangan']?.toString(),
      createdAt:
          DateTime.tryParse(m['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(m['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jenis_sedekah': jenisSedekah,
      'tanggal': FormatHelper.formatTimeAgo(tanggal),
      'jumlah': jumlah,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Statistik sedekah (total hari ini, total bulan ini, dan riwayat)
class StatistikSedekah {
  final int totalHariIni;
  final int totalBulanIni;
  final List<Sedekah> riwayat;

  StatistikSedekah({
    required this.totalHariIni,
    required this.totalBulanIni,
    required this.riwayat,
  });

  factory StatistikSedekah.empty() {
    return StatistikSedekah(totalHariIni: 0, totalBulanIni: 0, riwayat: []);
  }

  factory StatistikSedekah.fromJson(Map<String, dynamic> m) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final data =
        m['data'] ?? m; // fleksibel jika langsung objek "data" yg dikirim

    return StatistikSedekah(
      totalHariIni: toInt(data['total_hari_ini']),
      totalBulanIni: toInt(data['total_bulan_ini']),
      riwayat: (data['riwayat'] as List<dynamic>? ?? [])
          .map((e) => Sedekah.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hari_ini': totalHariIni,
      'total_bulan_ini': totalBulanIni,
      'riwayat': riwayat.map((e) => e.toJson()).toList(),
    };
  }
}
