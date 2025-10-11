class KategoriArtikel {
  final int id;
  final String nama;
  final String icon;

  KategoriArtikel({required this.id, required this.nama, required this.icon});

  factory KategoriArtikel.fromJson(Map<String, dynamic> json) {
    return KategoriArtikel(
      id: json['id'],
      nama: json['nama'],
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'icon': icon,
    };
  }
}
