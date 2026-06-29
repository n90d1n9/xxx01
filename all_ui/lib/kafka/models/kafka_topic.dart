class KafkaTopic {
  final String name;
  final int partitions;
  final int replicationFactor;

  KafkaTopic({
    required this.name,
    required this.partitions,
    required this.replicationFactor,
  });
}
