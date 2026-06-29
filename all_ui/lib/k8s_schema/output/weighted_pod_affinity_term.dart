import 'pod_affinity_term.dart';

class WeightedPodAffinityTerm {
  final int weight;
  final PodAffinityTerm podAffinityTerm;
  WeightedPodAffinityTerm({
    required this.weight,
    required this.podAffinityTerm,
  });
  factory WeightedPodAffinityTerm.fromJson(Map<String, dynamic> json) {
    return WeightedPodAffinityTerm(
      weight: json['weight'],
      podAffinityTerm: PodAffinityTerm.fromJson(json['podAffinityTerm']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'weight': weight, 'podAffinityTerm': podAffinityTerm.toJson()};
  }
}
