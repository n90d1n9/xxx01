import 'node_spec.dart';
import 'node_status.dart';
import 'object_meta.dart';

class Node {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final NodeSpec? spec;
  final NodeStatus? status;
  Node({
    this.apiVersion = 'v1',
    this.kind = 'Node',
    required this.metadata,
    this.spec,
    this.status,
  });
  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Node',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: json['spec'] != null ? NodeSpec.fromJson(json['spec']) : null,
      status:
          json['status'] != null ? NodeStatus.fromJson(json['status']) : null,
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
