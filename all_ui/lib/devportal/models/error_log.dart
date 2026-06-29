class ErrorLog {
  final String time;
  final String message;
  final String endpoint;
  final int status;

  ErrorLog({
    required this.time,
    required this.message,
    required this.endpoint,
    required this.status,
  });
}
