import 'pod_disruption_budget_condition.dart';

class PodDisruptionBudgetStatus {
  final int? observedGeneration;
  final Map<String, int>? disruptedPods;
  final int disruptionsAllowed;
  final int currentHealthy;
  final int desiredHealthy;
  final int expectedPods;
  final List<PodDisruptionBudgetCondition>? conditions;
  PodDisruptionBudgetStatus({
    this.observedGeneration,
    this.disruptedPods,
    required this.disruptionsAllowed,
    required this.currentHealthy,
    required this.desiredHealthy,
    required this.expectedPods,
    this.conditions,
  });
  factory PodDisruptionBudgetStatus.fromJson(Map<String, dynamic> json) {
    return PodDisruptionBudgetStatus(
      observedGeneration: json['observedGeneration'],
      disruptedPods:
          json['disruptedPods'] != null
              ? Map<String, int>.from(json['disruptedPods'])
              : null,
      disruptionsAllowed: json['disruptionsAllowed'],
      currentHealthy: json['currentHealthy'],
      desiredHealthy: json['desiredHealthy'],
      expectedPods: json['expectedPods'],
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => PodDisruptionBudgetCondition.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (observedGeneration != null) 'observedGeneration': observedGeneration,
      if (disruptedPods != null) 'disruptedPods': disruptedPods,
      'disruptionsAllowed': disruptionsAllowed,
      'currentHealthy': currentHealthy,
      'desiredHealthy': desiredHealthy,
      'expectedPods': expectedPods,
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
    };
  }
}
