import 'consumer_group.dart';
import 'metric_point.dart';

class TopicMetrics {
  final String name;
  final List<MetricPoint> messagesPerSecond;
  final List<MetricPoint> bytesInPerSecond;
  final List<MetricPoint> bytesOutPerSecond;
  final int? currentMessagesPerSecond;
  final int totalMessages;
  final double averageMessageSize;
  final int partitionCount;
  final String? replicationFactor;
  final int? underReplicatedPartitions;
  final bool isrShrinking;
  final double totalSizeBytes;
  final List<ConsumerGroup>? consumerGroups;
  final List<int>? partitionSizes;

  TopicMetrics({
    this.currentMessagesPerSecond,
    this.totalMessages = 0,
    this.averageMessageSize = 0,
    this.partitionCount = 0,
    this.replicationFactor,
    this.underReplicatedPartitions,
    this.isrShrinking = false,
    this.totalSizeBytes = 0,
    this.consumerGroups,
    this.partitionSizes,
    required this.name,
    required this.messagesPerSecond,
    required this.bytesInPerSecond,
    required this.bytesOutPerSecond,
  });
}
