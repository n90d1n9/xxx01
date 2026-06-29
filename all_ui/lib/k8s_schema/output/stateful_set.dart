import 'stateful_set_spec.dart';
import 'stateful_set_status.dart';
import 'object_meta.dart';

class StatefulSet {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final StatefulSetSpec spec;
  final StatefulSetStatus? status;
  StatefulSet({
    this.apiVersion = 'apps/v1',
    this.kind = 'StatefulSet',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory StatefulSet.fromJson(Map<String, dynamic> json) {
    return StatefulSet(
      apiVersion: json['apiVersion'] ?? 'apps/v1',
      kind: json['kind'] ?? 'StatefulSet',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: StatefulSetSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? StatefulSetStatus.fromJson(json['status'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'spec': spec.toJson(),
      if (status != null) 'status': status!.toJson(),
    };
  }
}
