import 'policy_rule.dart';
import 'object_meta.dart';

class Role {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final List<PolicyRule> rules;
  Role({
    this.apiVersion = 'rbac.authorization.k8s.io/v1',
    this.kind = 'Role',
    required this.metadata,
    required this.rules,
  });
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      apiVersion: json['apiVersion'] ?? 'rbac.authorization.k8s.io/v1',
      kind: json['kind'] ?? 'Role',
      metadata: ObjectMeta.fromJson(json['metadata']),
      rules:
          (json['rules'] as List).map((e) => PolicyRule.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'rules': rules.map((e) => e.toJson()).toList(),
    };
  }
}
