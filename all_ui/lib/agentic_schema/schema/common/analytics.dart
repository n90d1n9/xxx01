import '../discovery/logging.dart';
import '../discovery/tracing.dart';

class Analytics {
  final bool? enabled;
  final List<String>? metrics;
  final Logging? logging;
  final Tracing? tracing;

  Analytics({this.enabled = true, this.metrics, this.logging, this.tracing});

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      enabled: json['enabled'] as bool?,
      metrics: json['metrics'] != null
          ? List<String>.from(json['metrics'] as List)
          : null,
      logging: json['logging'] != null
          ? Logging.fromJson(json['logging'] as Map<String, dynamic>)
          : null,
      tracing: json['tracing'] != null
          ? Tracing.fromJson(json['tracing'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (metrics != null) 'metrics': metrics,
      if (logging != null) 'logging': logging!.toJson(),
      if (tracing != null) 'tracing': tracing!.toJson(),
    };
  }
}
