import 'deployment_condition.dart';

class DeploymentStatus {
  final int? observedGeneration;
  final int? replicas;
  final int? updatedReplicas;
  final int? readyReplicas;
  final int? availableReplicas;
  final int? unavailableReplicas;
  final List<DeploymentCondition>? conditions;
  final int? collisionCount;
  DeploymentStatus({
    this.observedGeneration,
    this.replicas,
    this.updatedReplicas,
    this.readyReplicas,
    this.availableReplicas,
    this.unavailableReplicas,
    this.conditions,
    this.collisionCount,
  });
  factory DeploymentStatus.fromJson(Map<String, dynamic> json) {
    return DeploymentStatus(
      observedGeneration: json['observedGeneration'],
      replicas: json['replicas'],
      updatedReplicas: json['updatedReplicas'],
      readyReplicas: json['readyReplicas'],
      availableReplicas: json['availableReplicas'],
      unavailableReplicas: json['unavailableReplicas'],
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => DeploymentCondition.fromJson(e))
                  .toList()
              : null,
      collisionCount: json['collisionCount'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (observedGeneration != null) 'observedGeneration': observedGeneration,
      if (replicas != null) 'replicas': replicas,
      if (updatedReplicas != null) 'updatedReplicas': updatedReplicas,
      if (readyReplicas != null) 'readyReplicas': readyReplicas,
      if (availableReplicas != null) 'availableReplicas': availableReplicas,
      if (unavailableReplicas != null)
        'unavailableReplicas': unavailableReplicas,
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
      if (collisionCount != null) 'collisionCount': collisionCount,
    };
  }
}
