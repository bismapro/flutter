class Sholat {
  final String tanggal;
  final SholatWajib wajib;
  final SholatSunnah sunnah;

  Sholat({required this.tanggal, required this.wajib, required this.sunnah});

  factory Sholat.fromJson(Map<String, dynamic> json) {
    return Sholat(
      tanggal: json['tanggal'],
      wajib: SholatWajib.fromJson(json['wajib']),
      sunnah: SholatSunnah.fromJson(json['sunnah']),
    );
  }

  factory Sholat.empty() {
    return Sholat(
      tanggal: '',
      wajib: SholatWajib(
        shubuh: '',
        dzuhur: '',
        ashar: '',
        maghrib: '',
        isya: '',
      ),
      sunnah: SholatSunnah(
        tahajud: '',
        witir: '',
        dhuha: '',
        qabliyahSubuh: '',
        qabliyahDzuhur: '',
        baDiyahDzuhur: '',
        qabliyahAshar: '',
        baDiyahMaghrib: '',
        qabliyahIsya: '',
        baDiyahIsya: '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'wajib': wajib.toJson(),
      'sunnah': sunnah.toJson(),
    };
  }
}

class SholatWajib {
  final String shubuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  SholatWajib({
    required this.shubuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory SholatWajib.fromJson(Map<String, dynamic> json) {
    return SholatWajib(
      shubuh: json['shubuh'] ?? '',
      dzuhur: json['dzuhur'] ?? '',
      ashar: json['ashar'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isya: json['isya'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shubuh': shubuh,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }

  // Get prayer time by name
  String getTimeByName(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
      case 'subuh':
      case 'shubuh':
        return shubuh;
      case 'dzuhur':
      case 'dhuhr':
        return dzuhur;
      case 'ashar':
      case 'asr':
        return ashar;
      case 'maghrib':
        return maghrib;
      case 'isya':
      case 'isha':
        return isya;
      default:
        return '';
    }
  }

  // Get all prayer times as list
  List<Map<String, String>> getAllPrayerTimes() {
    return [
      {'name': 'Fajr', 'time': shubuh},
      {'name': 'Dzuhr', 'time': dzuhur},
      {'name': 'Asr', 'time': ashar},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Isha', 'time': isya},
    ];
  }
}

class SholatSunnah {
  final String tahajud;
  final String witir;
  final String dhuha;
  final String qabliyahSubuh;
  final String qabliyahDzuhur;
  final String baDiyahDzuhur;
  final String qabliyahAshar;
  final String baDiyahMaghrib;
  final String qabliyahIsya;
  final String baDiyahIsya;

  SholatSunnah({
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

  factory SholatSunnah.fromJson(Map<String, dynamic> json) {
    return SholatSunnah(
      tahajud: json['tahajud'] ?? '',
      witir: json['witir'] ?? '',
      dhuha: json['dhuha'] ?? '',
      qabliyahSubuh: json['qabliyah_subuh'] ?? '',
      qabliyahDzuhur: json['qabliyah_dzuhur'] ?? '',
      baDiyahDzuhur: json['ba_diyah_dzuhur'] ?? '',
      qabliyahAshar: json['qabliyah_ashar'] ?? '',
      baDiyahMaghrib: json['ba_diyah_maghrib'] ?? '',
      qabliyahIsya: json['qabliyah_isya'] ?? '',
      baDiyahIsya: json['ba_diyah_isya'] ?? '',
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
