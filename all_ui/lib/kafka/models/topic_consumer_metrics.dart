class TopicConsumerMetrics {
  final String topicName;
  final int totalMessages;
  final int consumedMessages;
  final int consumerLag;
  final List<ConsumerGroup> consumerGroups;

  TopicConsumerMetrics({
    required this.topicName,
    required this.totalMessages,
    required this.consumedMessages,
    required this.consumerLag,
    required this.consumerGroups,
  });
}
