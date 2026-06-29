import 'health_check.dart';

class MonitoringConfig {
  final bool? enabled;
  final List<String>? metrics;
  final HealthCheck? healthCheck;

  MonitoringConfig({this.enabled = true, this.metrics, this.healthCheck});

  factory MonitoringConfig.fromJson(Map<String, dynamic> json) {
    return MonitoringConfig(
      enabled: json['enabled'] as bool?,
      metrics: json['metrics'] != null
          ? List<String>.from(json['metrics'] as List)
          : null,
      healthCheck: json['healthCheck'] != null
          ? HealthCheck.fromJson(json['healthCheck'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (metrics != null) 'metrics': metrics,
      if (healthCheck != null) 'healthCheck': healthCheck!.toJson(),
    };
  }
}
