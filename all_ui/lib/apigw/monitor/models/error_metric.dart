class ErrorMetrics {
  final int nginxErrors;

  ErrorMetrics({required this.nginxErrors});

  factory ErrorMetrics.fromJson(Map<String, dynamic> json) {
    return ErrorMetrics(nginxErrors: json['nginx_errors']);
  }
}
