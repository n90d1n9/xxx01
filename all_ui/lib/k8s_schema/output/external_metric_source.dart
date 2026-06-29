import 'metric_identifier.dart';
import 'metric_target.dart';

class ExternalMetricSource {
  final MetricIdentifier metric;
  final MetricTarget target;
  ExternalMetricSource({required this.metric, required this.target});
  factory ExternalMetricSource.fromJson(Map<String, dynamic> json) {
    return ExternalMetricSource(
      metric: MetricIdentifier.fromJson(json['metric']),
      target: MetricTarget.fromJson(json['target']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'metric': metric.toJson(), 'target': target.toJson()};
  }
}
