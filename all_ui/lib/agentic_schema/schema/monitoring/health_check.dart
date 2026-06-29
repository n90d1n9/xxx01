class HealthCheck {
  final bool? enabled;
  final int? interval;
  final String? endpoint;

  HealthCheck({this.enabled = true, this.interval = 30000, this.endpoint});

  factory HealthCheck.fromJson(Map<String, dynamic> json) {
    return HealthCheck(
      enabled: json['enabled'] as bool?,
      interval: json['interval'] as int?,
      endpoint: json['endpoint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (interval != null) 'interval': interval,
      if (endpoint != null) 'endpoint': endpoint,
    };
  }
}
