import 'object_meta.dart';
import 'pod_spec.dart';

class PodTemplateSpec {
  final ObjectMeta? metadata;
  final PodSpec spec;
  PodTemplateSpec({this.metadata, required this.spec});
  factory PodTemplateSpec.fromJson(Map<String, dynamic> json) {
    return PodTemplateSpec(
      metadata:
          json['metadata'] != null
              ? ObjectMeta.fromJson(json['metadata'])
              : null,
      spec: PodSpec.fromJson(json['spec']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (metadata != null) 'metadata': metadata!.toJson(),
      'spec': spec.toJson(),
    };
  }
}
