import 'ingress_spec.dart';
import 'ingress_status.dart';
import 'object_meta.dart';

class Ingress {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final IngressSpec spec;
  final IngressStatus? status;
  Ingress({
    this.apiVersion = 'networking.k8s.io/v1',
    this.kind = 'Ingress',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory Ingress.fromJson(Map<String, dynamic> json) {
    return Ingress(
      apiVersion: json['apiVersion'] ?? 'networking.k8s.io/v1',
      kind: json['kind'] ?? 'Ingress',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: IngressSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? IngressStatus.fromJson(json['status'])
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
