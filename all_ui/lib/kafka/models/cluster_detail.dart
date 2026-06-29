import 'broker.dart';
import 'kafka_cluster.dart';
import 'topic_detailed.dart';

class KafkaClusterDetailed {
  final String id;
  final String name;
  final String bootstrapServers;
  final List<KafkaBroker> brokers;
  final List<KafkaTopicDetailed> topics;
  final ClusterStatus status;

  KafkaClusterDetailed({
    required this.id,
    required this.name,
    required this.bootstrapServers,
    required this.brokers,
    required this.topics,
    required this.status,
  });
}
