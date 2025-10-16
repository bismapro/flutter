class Qori {
  final int id;
  final String name;

  Qori({required this.id, required this.name});

  factory Qori.fromJson(Map<String, dynamic> json) {
    return Qori(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  String get displayName {
    return name.replaceAll('-', ' ');
  }
}

class QoriListResponse {
  final bool status;
  final String message;
  final List<Qori> qoriList;

  QoriListResponse({
    required this.status,
    required this.message,
    required this.qoriList,
  });

  factory QoriListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final listQori = data?['list_qori'] as List<dynamic>? ?? [];

    return QoriListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      qoriList: listQori.map((e) => Qori.fromJson(e)).toList(),
    );
  }
}
