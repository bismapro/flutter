class KategoriKomunitas {
  final int id;
  final String nama;
  final String icon;

  KategoriKomunitas({required this.id, required this.nama, required this.icon});

  factory KategoriKomunitas.fromJson(Map<String, dynamic> json) {
    return KategoriKomunitas(
      id: json['id'],
      nama: json['nama'],
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'icon': icon};
  }
}
