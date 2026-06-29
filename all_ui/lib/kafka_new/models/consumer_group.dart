// Kafka Consumer Group Management
class ConsumerGroup {
  final String id;
  final String topic;
  final List<ConsumerMember> members;
  final Map<String, int> partitionAssignments;
  final String state;
  final double lagSum;
  final ConsumerMember? activeConsumers;
  final int totalLag;
  final int maxLag;
  final String? status;
  final DateTime? lastCommitTimestamp;

  ConsumerGroup({
    this.activeConsumers,
    this.totalLag = 0,
    this.maxLag = 0,
    this.status,
    this.lastCommitTimestamp,
    required this.id,
    required this.topic,
    required this.members,
    required this.partitionAssignments,
    required this.state,
    required this.lagSum,
  });

  factory ConsumerGroup.fromJson(Map<String, dynamic> json) {
    return ConsumerGroup(
      id: json['id'],
      topic: json['topic'],
      members:
          (json['members'] as List)
              .map((m) => ConsumerMember.fromJson(m))
              .toList(),
      partitionAssignments: Map.from(json['partitionAssignments']),
      state: json['state'],
      lagSum: json['lagSum'],
    );
  }
}

class ConsumerMember {
  final String id;
  final String clientId;
  final String host;
  final List<int> assignedPartitions;

  ConsumerMember({
    required this.id,
    required this.clientId,
    required this.host,
    required this.assignedPartitions,
  });

  factory ConsumerMember.fromJson(Map<String, dynamic> json) {
    return ConsumerMember(
      id: json['id'],
      clientId: json['clientId'],
      host: json['host'],
      assignedPartitions: List<int>.from(json['assignedPartitions']),
    );
  }
}
