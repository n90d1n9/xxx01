import 'pod_security_policy_spec.dart';
import 'object_meta.dart';

class PodSecurityPolicy {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final PodSecurityPolicySpec spec;
  PodSecurityPolicy({
    this.apiVersion = 'policy/v1beta1',
    this.kind = 'PodSecurityPolicy',
    required this.metadata,
    required this.spec,
  });
  factory PodSecurityPolicy.fromJson(Map<String, dynamic> json) {
    return PodSecurityPolicy(
      apiVersion: json['apiVersion'] ?? 'policy/v1beta1',
      kind: json['kind'] ?? 'PodSecurityPolicy',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: PodSecurityPolicySpec.fromJson(json['spec']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'spec': spec.toJson(),
    };
  }
}
