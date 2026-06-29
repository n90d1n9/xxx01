class KafkaCluster {
  final String id;
  final String name;
  final String endpoint;
  final String status;
  final int brokerCount;
  final int topicCount;

  KafkaCluster({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.status,
    required this.brokerCount,
    required this.topicCount,
  });

  factory KafkaCluster.fromJson(Map<String, dynamic> json) {
    return KafkaCluster(
      id: json['id'],
      name: json['name'],
      endpoint: json['endpoint'],
      status: json['status'],
      brokerCount: json['broker_count'],
      topicCount: json['topic_count'],
    );
  }
}
