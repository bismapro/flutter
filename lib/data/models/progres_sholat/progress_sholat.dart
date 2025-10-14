class ProgresSholat {
  final int id;
  final int userId;
  final String jenis; // wajib/sunnah
  final String sholat;
  final bool isOnTime; // "1" -> true, "0" -> false
  final bool isJamaah; // "1" -> true, "0" -> false
  final String lokasi;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgresSholat({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.sholat,
    required this.isOnTime,
    required this.isJamaah,
    required this.lokasi,
    required this.createdAt,
    required this.updatedAt,
  });

  static bool _parseBool(dynamic value) {
    if (value is String) return value == '1';
    if (value is int) return value == 1;
    return value ?? false;
  }

  factory ProgresSholat.fromJson(Map<String, dynamic> json) {
    return ProgresSholat(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      jenis: json['jenis'] as String? ?? '',
      sholat: json['sholat'] as String? ?? '',
      isOnTime: _parseBool(json['is_on_time']),
      isJamaah: _parseBool(json['is_jamaah']),
      lokasi: json['lokasi'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jenis': jenis,
      'sholat': sholat,
      'is_on_time': isOnTime ? '1' : '0',
      'is_jamaah': isJamaah ? '1' : '0',
      'lokasi': lokasi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProgresSholatWajib {
  final int total;
  final StatistikSholatWajib statistik;
  final List<ProgresSholat> detail;

  ProgresSholatWajib({
    required this.total,
    required this.statistik,
    required this.detail,
  });

  factory ProgresSholatWajib.empty() {
    return ProgresSholatWajib(
      total: 0,
      statistik: StatistikSholatWajib.empty(),
      detail: [],
    );
  }

  factory ProgresSholatWajib.fromJson(Map<String, dynamic> json) {
    var detailList = json['detail'] as List? ?? [];
    List<ProgresSholat> progresDetails = detailList
        .map((i) => ProgresSholat.fromJson(i))
        .toList();

    return ProgresSholatWajib(
      total: json['total'] as int? ?? 0,
      statistik: json['statistik'] != null
          ? StatistikSholatWajib.fromJson(json['statistik'])
          : StatistikSholatWajib.empty(),
      detail: progresDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'statistik': statistik.toJson(),
      'detail': detail.map((p) => p.toJson()).toList(),
    };
  }
}

class StatistikSholatWajib {
  final bool subuh;
  final bool dzuhur;
  final bool ashar;
  final bool maghrib;
  final bool isya;

  StatistikSholatWajib({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  // Factory constructor untuk membuat instance kosong
  factory StatistikSholatWajib.empty() {
    return StatistikSholatWajib(
      subuh: false,
      dzuhur: false,
      ashar: false,
      maghrib: false,
      isya: false,
    );
  }

  factory StatistikSholatWajib.fromJson(Map<String, dynamic> json) {
    return StatistikSholatWajib(
      subuh: json['subuh'] as bool? ?? false,
      dzuhur: json['dzuhur'] as bool? ?? false,
      ashar: json['ashar'] as bool? ?? false,
      maghrib: json['maghrib'] as bool? ?? false,
      isya: json['isya'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subuh': subuh,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }
}

class ProgresSholatSunnah {
  final int total;
  final StatistikSholatSunnah statistik;
  final List<ProgresSholat> detail;

  ProgresSholatSunnah({
    required this.total,
    required this.statistik,
    required this.detail,
  });

  factory ProgresSholatSunnah.empty() {
    return ProgresSholatSunnah(
      total: 0,
      statistik: StatistikSholatSunnah.empty(),
      detail: [],
    );
  }

  factory ProgresSholatSunnah.fromJson(Map<String, dynamic> json) {
    var detailList = json['detail'] as List? ?? [];
    List<ProgresSholat> progresDetails = detailList
        .map((i) => ProgresSholat.fromJson(i))
        .toList();

    return ProgresSholatSunnah(
      total: json['total'] as int? ?? 0,
      statistik: json['statistik'] != null
          ? StatistikSholatSunnah.fromJson(json['statistik'])
          : StatistikSholatSunnah.empty(),
      detail: progresDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'statistik': statistik.toJson(),
      'detail': detail.map((p) => p.toJson()).toList(),
    };
  }
}

/// Model untuk objek "statistik" pada respons Sholat Sunnah
class StatistikSholatSunnah {
  final bool tahajud;
  final bool witir;
  final bool dhuha;
  final bool qabliyahSubuh;
  final bool qabliyahDzuhur;
  final bool baDiyahDzuhur;
  final bool qabliyahAshar;
  final bool baDiyahMaghrib;
  final bool qabliyahIsya;
  final bool baDiyahIsya;

  StatistikSholatSunnah({
    required this.tahajud,
    required this.witir,
    required this.dhuha,
    required this.qabliyahSubuh,
    required this.qabliyahDzuhur,
    required this.baDiyahDzuhur,
    required this.qabliyahAshar,
    required this.baDiyahMaghrib,
    required this.qabliyahIsya,
    required this.baDiyahIsya,
  });

  factory StatistikSholatSunnah.empty() {
    return StatistikSholatSunnah(
      tahajud: false,
      witir: false,
      dhuha: false,
      qabliyahSubuh: false,
      qabliyahDzuhur: false,
      baDiyahDzuhur: false,
      qabliyahAshar: false,
      baDiyahMaghrib: false,
      qabliyahIsya: false,
      baDiyahIsya: false,
    );
  }

  factory StatistikSholatSunnah.fromJson(Map<String, dynamic> json) {
    return StatistikSholatSunnah(
      tahajud: json['tahajud'] as bool? ?? false,
      witir: json['witir'] as bool? ?? false,
      dhuha: json['dhuha'] as bool? ?? false,
      qabliyahSubuh: json['qabliyah_subuh'] as bool? ?? false,
      qabliyahDzuhur: json['qabliyah_dzuhur'] as bool? ?? false,
      baDiyahDzuhur: json['ba_diyah_dzuhur'] as bool? ?? false,
      qabliyahAshar: json['qabliyah_ashar'] as bool? ?? false,
      baDiyahMaghrib: json['ba_diyah_maghrib'] as bool? ?? false,
      qabliyahIsya: json['qabliyah_isya'] as bool? ?? false,
      baDiyahIsya: json['ba_diyah_isya'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tahajud': tahajud,
      'witir': witir,
      'dhuha': dhuha,
      'qabliyah_subuh': qabliyahSubuh,
      'qabliyah_dzuhur': qabliyahDzuhur,
      'ba_diyah_dzuhur': baDiyahDzuhur,
      'qabliyah_ashar': qabliyahAshar,
      'ba_diyah_maghrib': baDiyahMaghrib,
      'qabliyah_isya': qabliyahIsya,
      'ba_diyah_isya': baDiyahIsya,
    };
  }
}

class RiwayatProgres {
  final Map<String, List<ProgresSholat>> data;

  RiwayatProgres({required this.data});

  factory RiwayatProgres.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ProgresSholat>> riwayatData = json.map((
      tanggal,
      listData,
    ) {
      final listProgres = listData is List
          ? listData
                .map(
                  (item) =>
                      ProgresSholat.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : <ProgresSholat>[]; // Jika bukan list, kembalikan list kosong

      return MapEntry(tanggal, listProgres);
    });

    return RiwayatProgres(data: riwayatData);
  }

  Map<String, dynamic> toJson() {
    return data.map((tanggal, listProgres) {
      final listJson = listProgres.map((item) => item.toJson()).toList();
      return MapEntry(tanggal, listJson);
    });
  }
}
