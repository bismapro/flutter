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
      userId: json['user_id'] ?? 0, // ✅ Fixed typo: was 'user_d'
      suratId: json['surat_id'] ?? 0, // ✅ Fixed typo: was 'surat_d'
      ayat: json['ayat'] ?? 0,
      createdAt: json['created_at'],
      surat: json['surat'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // ✅ Fixed: was 'userId'
      'surat_id': suratId, // ✅ Fixed: was 'suratId'
      'ayat': ayat,
      'created_at': createdAt, // ✅ Fixed: was 'createdAt'
      'surat': surat,
    };
  }
}
