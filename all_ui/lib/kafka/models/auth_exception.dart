class KafkaAuthenticationException implements Exception {
  final String message;
  final String details;

  KafkaAuthenticationException({required this.message, required this.details});
}
