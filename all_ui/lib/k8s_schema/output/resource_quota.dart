import 'resource_quota_spec.dart';
import 'resource_quota_status.dart';
import 'object_meta.dart';

class ResourceQuota {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final ResourceQuotaSpec? spec;
  final ResourceQuotaStatus? status;
  ResourceQuota({
    this.apiVersion = 'v1',
    this.kind = 'ResourceQuota',
    required this.metadata,
    this.spec,
    this.status,
  });
  factory ResourceQuota.fromJson(Map<String, dynamic> json) {
    return ResourceQuota(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'ResourceQuota',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec:
          json['spec'] != null
              ? ResourceQuotaSpec.fromJson(json['spec'])
              : null,
      status:
          json['status'] != null
              ? ResourceQuotaStatus.fromJson(json['status'])
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
