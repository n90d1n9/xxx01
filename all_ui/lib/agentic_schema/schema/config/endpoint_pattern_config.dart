import '../common/endpoint_pattern_settings.dart';

enum EndpointPattern {
  messagingGateway,
  messagingMapper,
  transactionalClient,
  pollingConsumer,
  eventDrivenConsumer,
  serviceActivator,
  messagingAdapter,
}

class EndpointPatternConfig {
  final EndpointPattern pattern;
  final EndpointPatternSettings? config;

  EndpointPatternConfig({required this.pattern, this.config});

  factory EndpointPatternConfig.fromJson(Map<String, dynamic> json) {
    return EndpointPatternConfig(
      pattern: _parseEndpointPattern(json['pattern']),
      config: json['config'] != null
          ? EndpointPatternSettings.fromJson(
              json['config'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern.name,
      if (config != null) 'config': config!.toJson(),
    };
  }

  static EndpointPattern _parseEndpointPattern(dynamic value) {
    if (value is EndpointPattern) return value;
    final stringValue = value.toString();
    return EndpointPattern.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => EndpointPattern.messagingGateway,
    );
  }
}
