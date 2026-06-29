class KafkaConnectionException implements Exception {
  final String message;
  final String details;

  KafkaConnectionException({required this.message, required this.details});
}
