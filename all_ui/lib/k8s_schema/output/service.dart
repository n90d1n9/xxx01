import 'object_meta.dart';
import 'service_spec.dart';
import 'service_status.dart';

class Service {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final ServiceSpec spec;
  final ServiceStatus? status;
  Service({
    this.apiVersion = 'v1',
    this.kind = 'Service',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Service',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: ServiceSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? ServiceStatus.fromJson(json['status'])
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
