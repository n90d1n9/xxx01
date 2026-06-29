class KafkaFetchException implements Exception {
  final String message;
  final String details;

  KafkaFetchException({required this.message, required this.details});
}
