class KafkaTopicDetailed {
  final String name;
  final int partitions;
  final int replicationFactor;
  // Additional configurable parameters
  final Map<String, String>? configs;

  KafkaTopicDetailed({
    required this.name,
    required this.partitions,
    required this.replicationFactor,
    this.configs,
  });
}
