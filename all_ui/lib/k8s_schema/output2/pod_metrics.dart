import 'container_metrics.dart';
import 'object_meta.dart';

class PodMetrics {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final DateTime timestamp;
  final DateTime window;
  final List<ContainerMetrics> containers;
  PodMetrics({
    this.apiVersion = 'metrics.k8s.io/v1beta1',
    this.kind = 'PodMetrics',
    required this.metadata,
    required this.timestamp,
    required this.window,
    required this.containers,
  });
  factory PodMetrics.fromJson(Map<String, dynamic> json) {
    return PodMetrics(
      apiVersion: json['apiVersion'] ?? 'metrics.k8s.io/v1beta1',
      kind: json['kind'] ?? 'PodMetrics',
      metadata: ObjectMeta.fromJson(json['metadata']),
      timestamp: DateTime.parse(json['timestamp']),
      window: DateTime.parse(json['window']),
      containers:
          (json['containers'] as List)
              .map((e) => ContainerMetrics.fromJson(e))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'window': window.toIso8601String(),
      'containers': containers.map((e) => e.toJson()).toList(),
    };
  }
}
