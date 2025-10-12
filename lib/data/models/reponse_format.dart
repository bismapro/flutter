class ResponseFormat {
  final bool status;
  final String message;
  final dynamic data;

  ResponseFormat({required this.status, required this.message, this.data});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    return ResponseFormat(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );
  }
}
