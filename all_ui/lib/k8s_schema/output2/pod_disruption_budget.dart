import 'pod_disruption_budget_spec.dart';
import 'pod_disruption_budget_status.dart';
import 'object_meta.dart';

class PodDisruptionBudget {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final PodDisruptionBudgetSpec? spec;
  final PodDisruptionBudgetStatus? status;
  PodDisruptionBudget({
    this.apiVersion = 'policy/v1',
    this.kind = 'PodDisruptionBudget',
    required this.metadata,
    this.spec,
    this.status,
  });
  factory PodDisruptionBudget.fromJson(Map<String, dynamic> json) {
    return PodDisruptionBudget(
      apiVersion: json['apiVersion'] ?? 'policy/v1',
      kind: json['kind'] ?? 'PodDisruptionBudget',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec:
          json['spec'] != null
              ? PodDisruptionBudgetSpec.fromJson(json['spec'])
              : null,
      status:
          json['status'] != null
              ? PodDisruptionBudgetStatus.fromJson(json['status'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (spec != null) 'spec': spec!.toJson(),
      if (status != null) 'status': status!.toJson(),
    };
  }
}
