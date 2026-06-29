import 'subject.dart';
import 'role_ref.dart';
import 'object_meta.dart';

class RoleBinding {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final List<Subject> subjects;
  final RoleRef roleRef;
  RoleBinding({
    this.apiVersion = 'rbac.authorization.k8s.io/v1',
    this.kind = 'RoleBinding',
    required this.metadata,
    required this.subjects,
    required this.roleRef,
  });
  factory RoleBinding.fromJson(Map<String, dynamic> json) {
    return RoleBinding(
      apiVersion: json['apiVersion'] ?? 'rbac.authorization.k8s.io/v1',
      kind: json['kind'] ?? 'RoleBinding',
      metadata: ObjectMeta.fromJson(json['metadata']),
      subjects:
          (json['subjects'] as List).map((e) => Subject.fromJson(e)).toList(),
      roleRef: RoleRef.fromJson(json['roleRef']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'roleRef': roleRef.toJson(),
    };
  }
}
