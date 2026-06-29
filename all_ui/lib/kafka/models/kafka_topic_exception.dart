class KafkaTopicException implements Exception {
  final String message;
  final String details;

  KafkaTopicException({required this.message, required this.details});
}
