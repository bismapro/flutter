class ProgresPuasa {
  final int id;
  final int userId;
  final String jenis;
  final int tahunHijriah;
  final int? tanggalRamadhan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgresPuasa({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.tahunHijriah,
    this.tanggalRamadhan,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgresPuasa.fromJson(Map<String, dynamic> json) {
    return ProgresPuasa(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      jenis: json['jenis'] ?? '',
      tahunHijriah: json['tahun_hijriah'] ?? 0,
      tanggalRamadhan: json['tanggal_ramadhan'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jenis': jenis,
      'tahun_hijriah': tahunHijriah,
      'tanggal_ramadhan': tanggalRamadhan,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ProgresPuasaWajibTahunIni {
  final int total;
  final Map<String, dynamic> detail;

  ProgresPuasaWajibTahunIni({required this.total, required this.detail});

  factory ProgresPuasaWajibTahunIni.fromJson(Map<String, dynamic> json) {
    return ProgresPuasaWajibTahunIni(
      total: json['total'] ?? 0,
      detail: Map<String, dynamic>.from(json['detail'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'detail': detail};
  }
}

class RiwayatPuasaWajib {
  final int tahun;
  final List<ProgresPuasa> data;

  RiwayatPuasaWajib({required this.tahun, required this.data});

  factory RiwayatPuasaWajib.fromJson(Map<String, dynamic> json) {
    return RiwayatPuasaWajib(
      tahun: json['tahun'] ?? 0,
      data: List<ProgresPuasa>.from(
        json['data']?.map((item) => ProgresPuasa.fromJson(item)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tahun': tahun, 'data': data.map((item) => item.toJson()).toList()};
  }
}

class ProgresPuasaSunnahTahunIni {
  final int total;
  final List<ProgresPuasa> detail;

  ProgresPuasaSunnahTahunIni({required this.total, required this.detail});

  factory ProgresPuasaSunnahTahunIni.fromJson(Map<String, dynamic> json) {
    return ProgresPuasaSunnahTahunIni(
      total: json['total'] ?? 0,
      detail: List<ProgresPuasa>.from(
        json['detail']?.map((item) => ProgresPuasa.fromJson(item)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'detail': detail.map((item) => item.toJson()).toList(),
    };
  }
}

class RiwayatPuasaSunnah {
  final int total;
  final List<ProgresPuasa> detail;

  RiwayatPuasaSunnah({required this.total, required this.detail});

  factory RiwayatPuasaSunnah.fromJson(Map<String, dynamic> json) {
    return RiwayatPuasaSunnah(
      total: json['total'] ?? 0,
      detail: List<ProgresPuasa>.from(
        json['detail']?.map((item) => ProgresPuasa.fromJson(item)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'detail': detail.map((item) => item.toJson()).toList(),
    };
  }
}
