class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? errorCode;
  final DateTime? timestamp;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null
          ? fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'] as T
          : null,
      errorCode: json['errorCode'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null
          ? toJsonT != null
              ? toJsonT(data as T)
              : data
          : null,
      'errorCode': errorCode,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
