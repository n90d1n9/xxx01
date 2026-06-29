import 'apiservice_spec.dart';
import 'apiservice_status.dart';
import 'object_meta.dart';

class APIService {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final APIServiceSpec spec;
  final APIServiceStatus? status;
  APIService({
    this.apiVersion = 'apiregistration.k8s.io/v1',
    this.kind = 'APIService',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory APIService.fromJson(Map<String, dynamic> json) {
    return APIService(
      apiVersion: json['apiVersion'] ?? 'apiregistration.k8s.io/v1',
      kind: json['kind'] ?? 'APIService',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: APIServiceSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? APIServiceStatus.fromJson(json['status'])
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
