import 'metric_target.dart';

class ResourceMetricSource {
  final String name;
  final MetricTarget target;
  ResourceMetricSource({required this.name, required this.target});
  factory ResourceMetricSource.fromJson(Map<String, dynamic> json) {
    return ResourceMetricSource(
      name: json['name'],
      target: MetricTarget.fromJson(json['target']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'target': target.toJson()};
  }
}
