import 'object_meta.dart';
import 'pod_spec.dart';
import 'pod_status.dart';

class Pod {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final PodSpec spec;
  final PodStatus? status;
  Pod({
    this.apiVersion = 'v1',
    this.kind = 'Pod',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Pod',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: PodSpec.fromJson(json['spec']),
      status:
          json['status'] != null ? PodStatus.fromJson(json['status']) : null,
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
