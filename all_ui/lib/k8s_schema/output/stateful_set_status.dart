import 'stateful_set_condition.dart';

class StatefulSetStatus {
  final int? observedGeneration;
  final int replicas;
  final int? readyReplicas;
  final int? currentReplicas;
  final int? updatedReplicas;
  final String? currentRevision;
  final String? updateRevision;
  final int? collisionCount;
  final List<StatefulSetCondition>? conditions;
  StatefulSetStatus({
    this.observedGeneration,
    required this.replicas,
    this.readyReplicas,
    this.currentReplicas,
    this.updatedReplicas,
    this.currentRevision,
    this.updateRevision,
    this.collisionCount,
    this.conditions,
  });
  factory StatefulSetStatus.fromJson(Map<String, dynamic> json) {
    return StatefulSetStatus(
      observedGeneration: json['observedGeneration'],
      replicas: json['replicas'],
      readyReplicas: json['readyReplicas'],
      currentReplicas: json['currentReplicas'],
      updatedReplicas: json['updatedReplicas'],
      currentRevision: json['currentRevision'],
      updateRevision: json['updateRevision'],
      collisionCount: json['collisionCount'],
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => StatefulSetCondition.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (observedGeneration != null) 'observedGeneration': observedGeneration,
      'replicas': replicas,
      if (readyReplicas != null) 'readyReplicas': readyReplicas,
      if (currentReplicas != null) 'currentReplicas': currentReplicas,
      if (updatedReplicas != null) 'updatedReplicas': updatedReplicas,
      if (currentRevision != null) 'currentRevision': currentRevision,
      if (updateRevision != null) 'updateRevision': updateRevision,
      if (collisionCount != null) 'collisionCount': collisionCount,
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
    };
  }
}
