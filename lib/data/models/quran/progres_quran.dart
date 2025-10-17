class ProgresQuran {
  final int id;
  final int userId;
  final String suratId;
  final String ayat;
  final String? createdAt;
  final String? updatedAt;

  ProgresQuran({
    required this.id,
    required this.userId,
    required this.suratId,
    required this.ayat,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgresQuran.fromJson(Map<String, dynamic> json) {
    return ProgresQuran(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      suratId: json['suratId'] ?? '',
      ayat: json['ayat'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'suratId': suratId,
      'ayat': ayat,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ProgresBacaQuran {
  final int id;
  final int userId;
  final int suratId;
  final int ayat;
  final String? createdAt;
  final Map<String, dynamic>? surat;

  ProgresBacaQuran({
    required this.id,
    required this.userId,
    required this.suratId,
    required this.ayat,
    this.createdAt,
    this.surat,
  });

  factory ProgresBacaQuran.fromJson(Map<String, dynamic> json) {
    return ProgresBacaQuran(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      suratId: json['suratId'] ?? 0,
      ayat: json['ayat'] ?? 0,
      createdAt: json['createdAt'],
      surat: json['surat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'suratId': suratId,
      'ayat': ayat,
      'createdAt': createdAt,
      'surat': surat,
    };
  }
}
