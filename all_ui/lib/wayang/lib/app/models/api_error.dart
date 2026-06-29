class ApiError {
  final String errorId;
  final String message;
  final String? detail;
  final String? path;
  final DateTime timestamp;
  final int status;

  ApiError({
    required this.errorId,
    required this.message,
    this.detail,
    this.path,
    required this.timestamp,
    required this.status,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      errorId: json['errorId'] as String,
      message: json['message'] as String,
      detail: json['detail'] as String?,
      path: json['path'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorId': errorId,
      'message': message,
      'detail': detail,
      'path': path,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}
