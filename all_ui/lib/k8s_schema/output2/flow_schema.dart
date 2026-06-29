import 'flow_schema_spec.dart';
import 'flow_schema_status.dart';
import 'object_meta.dart';

class FlowSchema {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final FlowSchemaSpec spec;
  final FlowSchemaStatus? status;
  FlowSchema({
    this.apiVersion = 'flowcontrol.apiserver.k8s.io/v1beta3',
    this.kind = 'FlowSchema',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory FlowSchema.fromJson(Map<String, dynamic> json) {
    return FlowSchema(
      apiVersion: json['apiVersion'] ?? 'flowcontrol.apiserver.k8s.io/v1beta3',
      kind: json['kind'] ?? 'FlowSchema',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: FlowSchemaSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? FlowSchemaStatus.fromJson(json['status'])
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
