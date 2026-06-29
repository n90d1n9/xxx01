// Enum for cluster status
enum ClusterStatus { healthy, warning, critical }

// Model class for Kafka Cluster

class KafkaCluster {
  final String name;
  final String bootstrapServers;
  final int brokers;
  final int topics;
  final ClusterStatus status;

  KafkaCluster({
    required this.name,
    required this.bootstrapServers,
    required this.brokers,
    required this.topics,
    required this.status,
  });
}
