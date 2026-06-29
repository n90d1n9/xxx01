import '../models/kafka_cluster.dart';

class KafkaService {
  final KafkaClient _client;
  final BehaviorSubject<List<KafkaCluster>> _clustersController =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<KafkaTopic>> _topicsController =
      BehaviorSubject.seeded([]);

  Stream<List<KafkaCluster>> get clustersStream => _clustersController.stream;
  Stream<List<KafkaTopic>> get topicsStream => _topicsController.stream;

  KafkaService(this._client);

  Future<void> connectToCluster(String bootstrapServers) async {
    try {
      await _client.connect(bootstrapServers);

      // Fetch cluster metadata
      final metadata = await _client.getClusterMetadata();

      final cluster = KafkaCluster(
        name: 'Dynamic Cluster',
        bootstrapServers: bootstrapServers,
        brokers: metadata.brokers.length,
        topics: metadata.topics.length,
        status: _determineClusterStatus(metadata),
      );

      final currentClusters = _clustersController.value;
      currentClusters.add(cluster);
      _clustersController.add(currentClusters);
    } catch (e) {
      throw KafkaConnectionException(
        message: 'Failed to connect to Kafka cluster',
        details: e.toString(),
      );
    }
  }

  Future<void> fetchTopics(String clusterId) async {
    try {
      final topics = await _client.listTopics();
      _topicsController.add(
        topics
            .map(
              (topic) => KafkaTopic(
                name: topic.name,
                partitions: topic.partitions.length,
                replicationFactor: topic.replicationFactor,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw KafkaFetchException(
        message: 'Failed to fetch topics',
        details: e.toString(),
      );
    }
  }

  Future<void> createTopic(
    String topicName, {
    int partitions = 1,
    int replicationFactor = 1,
  }) async {
    try {
      await _client.createTopic(
        topicName,
        numPartitions: partitions,
        replicationFactor: replicationFactor,
      );

      // Refresh topics after creation
      await fetchTopics('current');
    } catch (e) {
      throw KafkaTopicException(
        message: 'Failed to create topic',
        details: e.toString(),
      );
    }
  }

  ClusterStatus _determineClusterStatus(ClusterMetadata metadata) {
    if (metadata.brokers.isEmpty) return ClusterStatus.critical;
    if (metadata.brokers.length < 3) return ClusterStatus.warning;
    return ClusterStatus.healthy;
  }

  void dispose() {
    _clustersController.close();
    _topicsController.close();
    _client.close();
  }
}
