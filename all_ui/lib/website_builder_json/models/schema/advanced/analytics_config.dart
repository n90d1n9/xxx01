import 'analytics_event.dart';

class AnalyticsConfig {
  final bool enabled;
  final String provider; // google, mixpanel, segment, custom
  final String? trackingId;
  final Map<String, dynamic>? config;
  final List<AnalyticsEvent>? customEvents;

  AnalyticsConfig({
    required this.enabled,
    required this.provider,
    this.trackingId,
    this.config,
    this.customEvents,
  });

  factory AnalyticsConfig.fromJson(Map<String, dynamic> json) {
    return AnalyticsConfig(
      enabled: json['enabled'] as bool,
      provider: json['provider'] as String,
      trackingId: json['trackingId'] as String?,
      config: json['config'] as Map<String, dynamic>?,
      customEvents:
          json['customEvents'] != null
              ? (json['customEvents'] as List)
                  .map(
                    (e) => AnalyticsEvent.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'provider': provider,
    if (trackingId != null) 'trackingId': trackingId,
    if (config != null) 'config': config,
    if (customEvents != null)
      'customEvents': customEvents!.map((e) => e.toJson()).toList(),
  };
}
