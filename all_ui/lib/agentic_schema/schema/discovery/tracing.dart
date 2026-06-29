class Tracing {
  final bool? enabled;
  final String? provider;
  final double? samplingRate;

  Tracing({
    this.enabled = false,
    this.provider = 'jaeger',
    this.samplingRate = 0.1,
  });

  factory Tracing.fromJson(Map<String, dynamic> json) {
    return Tracing(
      enabled: json['enabled'] as bool?,
      provider: json['provider'] as String?,
      samplingRate: json['samplingRate'] != null
          ? (json['samplingRate'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (provider != null) 'provider': provider,
      if (samplingRate != null) 'samplingRate': samplingRate,
    };
  }
}
