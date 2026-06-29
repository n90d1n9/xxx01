import 'pod_affinity_term.dart';
import 'weighted_pod_affinity_term.dart';

class PodAffinity {
  final List<PodAffinityTerm>? requiredDuringSchedulingIgnoredDuringExecution;
  final List<WeightedPodAffinityTerm>?
  preferredDuringSchedulingIgnoredDuringExecution;
  PodAffinity({
    this.requiredDuringSchedulingIgnoredDuringExecution,
    this.preferredDuringSchedulingIgnoredDuringExecution,
  });
  factory PodAffinity.fromJson(Map<String, dynamic> json) {
    return PodAffinity(
      requiredDuringSchedulingIgnoredDuringExecution:
          json['requiredDuringSchedulingIgnoredDuringExecution'] != null
              ? (json['requiredDuringSchedulingIgnoredDuringExecution'] as List)
                  .map((e) => PodAffinityTerm.fromJson(e))
                  .toList()
              : null,
      preferredDuringSchedulingIgnoredDuringExecution:
          json['preferredDuringSchedulingIgnoredDuringExecution'] != null
              ? (json['preferredDuringSchedulingIgnoredDuringExecution']
                      as List)
                  .map((e) => WeightedPodAffinityTerm.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (requiredDuringSchedulingIgnoredDuringExecution != null)
        'requiredDuringSchedulingIgnoredDuringExecution':
            requiredDuringSchedulingIgnoredDuringExecution!
                .map((e) => e.toJson())
                .toList(),
      if (preferredDuringSchedulingIgnoredDuringExecution != null)
        'preferredDuringSchedulingIgnoredDuringExecution':
            preferredDuringSchedulingIgnoredDuringExecution!
                .map((e) => e.toJson())
                .toList(),
    };
  }
}
