import 'metric_status.dart';
import 'horizontal_pod_autoscaler_condition.dart';

class HorizontalPodAutoscalerStatus {
  final int? observedGeneration;
  final DateTime? lastScaleTime;
  final int currentReplicas;
  final int desiredReplicas;
  final List<MetricStatus>? currentMetrics;
  final List<HorizontalPodAutoscalerCondition>? conditions;
  HorizontalPodAutoscalerStatus({
    this.observedGeneration,
    this.lastScaleTime,
    required this.currentReplicas,
    required this.desiredReplicas,
    this.currentMetrics,
    this.conditions,
  });
  factory HorizontalPodAutoscalerStatus.fromJson(Map<String, dynamic> json) {
    return HorizontalPodAutoscalerStatus(
      observedGeneration: json['observedGeneration'],
      lastScaleTime:
          json['lastScaleTime'] != null
              ? DateTime.parse(json['lastScaleTime'])
              : null,
      currentReplicas: json['currentReplicas'],
      desiredReplicas: json['desiredReplicas'],
      currentMetrics:
          json['currentMetrics'] != null
              ? (json['currentMetrics'] as List)
                  .map((e) => MetricStatus.fromJson(e))
                  .toList()
              : null,
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => HorizontalPodAutoscalerCondition.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (observedGeneration != null) 'observedGeneration': observedGeneration,
      if (lastScaleTime != null)
        'lastScaleTime': lastScaleTime!.toIso8601String(),
      'currentReplicas': currentReplicas,
      'desiredReplicas': desiredReplicas,
      if (currentMetrics != null)
        'currentMetrics': currentMetrics!.map((e) => e.toJson()).toList(),
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
    };
  }
}
