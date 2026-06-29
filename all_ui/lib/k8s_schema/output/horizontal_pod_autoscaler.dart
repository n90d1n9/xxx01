import 'horizontal_pod_autoscaler_spec.dart';
import 'horizontal_pod_autoscaler_status.dart';
import 'object_meta.dart';

class HorizontalPodAutoscaler {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final HorizontalPodAutoscalerSpec spec;
  final HorizontalPodAutoscalerStatus? status;
  HorizontalPodAutoscaler({
    this.apiVersion = 'autoscaling/v2',
    this.kind = 'HorizontalPodAutoscaler',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory HorizontalPodAutoscaler.fromJson(Map<String, dynamic> json) {
    return HorizontalPodAutoscaler(
      apiVersion: json['apiVersion'] ?? 'autoscaling/v2',
      kind: json['kind'] ?? 'HorizontalPodAutoscaler',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: HorizontalPodAutoscalerSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? HorizontalPodAutoscalerStatus.fromJson(json['status'])
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
