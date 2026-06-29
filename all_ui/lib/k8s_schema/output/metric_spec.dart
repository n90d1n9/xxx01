import 'object_metric_source.dart';
import 'pods_metric_source.dart';
import 'resource_metric_source.dart';
import 'container_resource_metric_source.dart';
import 'external_metric_source.dart';

class MetricSpec {
  final String type;
  final ObjectMetricSource? object;
  final PodsMetricSource? pods;
  final ResourceMetricSource? resource;
  final ContainerResourceMetricSource? containerResource;
  final ExternalMetricSource? external;
  MetricSpec({
    required this.type,
    this.object,
    this.pods,
    this.resource,
    this.containerResource,
    this.external,
  });
  factory MetricSpec.fromJson(Map<String, dynamic> json) {
    return MetricSpec(
      type: json['type'],
      object:
          json['object'] != null
              ? ObjectMetricSource.fromJson(json['object'])
              : null,
      pods:
          json['pods'] != null ? PodsMetricSource.fromJson(json['pods']) : null,
      resource:
          json['resource'] != null
              ? ResourceMetricSource.fromJson(json['resource'])
              : null,
      containerResource:
          json['containerResource'] != null
              ? ContainerResourceMetricSource.fromJson(
                json['containerResource'],
              )
              : null,
      external:
          json['external'] != null
              ? ExternalMetricSource.fromJson(json['external'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (object != null) 'object': object!.toJson(),
      if (pods != null) 'pods': pods!.toJson(),
      if (resource != null) 'resource': resource!.toJson(),
      if (containerResource != null)
        'containerResource': containerResource!.toJson(),
      if (external != null) 'external': external!.toJson(),
    };
  }
}
