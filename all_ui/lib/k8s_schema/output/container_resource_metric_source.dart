import 'metric_target.dart';

class ContainerResourceMetricSource {
  final String name;
  final String container;
  final MetricTarget target;
  ContainerResourceMetricSource({
    required this.name,
    required this.container,
    required this.target,
  });
  factory ContainerResourceMetricSource.fromJson(Map<String, dynamic> json) {
    return ContainerResourceMetricSource(
      name: json['name'],
      container: json['container'],
      target: MetricTarget.fromJson(json['target']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'container': container, 'target': target.toJson()};
  }
}
