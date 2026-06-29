class KafkaTopic {
  final String name;
  final int partitions;
  final int replicationFactor;
  final Map<String, dynamic> configs;
  final int messageCount;
  final double throughput;

  KafkaTopic({
    required this.name,
    required this.partitions,
    required this.replicationFactor,
    required this.configs,
    required this.messageCount,
    required this.throughput,
  });

  factory KafkaTopic.fromJson(Map<String, dynamic> json) {
    return KafkaTopic(
      name: json['name'],
      partitions: json['partitions'],
      replicationFactor: json['replication_factor'],
      configs: json['configs'] ?? {},
      messageCount: json['message_count'] ?? 0,
      throughput: json['throughput'] ?? 0.0,
    );
  }
}
