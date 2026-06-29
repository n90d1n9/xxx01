import 'hpascaling_policy.dart';

class HPAScalingRules {
  final int? stabilizationWindowSeconds;
  final String? selectPolicy;
  final List<HPAScalingPolicy>? policies;
  HPAScalingRules({
    this.stabilizationWindowSeconds,
    this.selectPolicy,
    this.policies,
  });
  factory HPAScalingRules.fromJson(Map<String, dynamic> json) {
    return HPAScalingRules(
      stabilizationWindowSeconds: json['stabilizationWindowSeconds'],
      selectPolicy: json['selectPolicy'],
      policies:
          json['policies'] != null
              ? (json['policies'] as List)
                  .map((e) => HPAScalingPolicy.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (stabilizationWindowSeconds != null)
        'stabilizationWindowSeconds': stabilizationWindowSeconds,
      if (selectPolicy != null) 'selectPolicy': selectPolicy,
      if (policies != null)
        'policies': policies!.map((e) => e.toJson()).toList(),
    };
  }
}
