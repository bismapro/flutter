class PaginatedResponse<T> {
  final bool status;
  final String message;
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final pagination = json['data'];

    return PaginatedResponse<T>(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (pagination['data'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
      perPage: pagination['per_page'] ?? 10,
      total: pagination['total'] ?? 0,
    );
  }
}
