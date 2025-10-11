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
