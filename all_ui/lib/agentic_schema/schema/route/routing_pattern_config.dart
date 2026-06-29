import 'routing_pattern_settings.dart';

enum RoutingPattern {
  contentBasedRouter,
  messageFilter,
  dynamicRouter,
  recipientList,
  splitter,
  aggregator,
  resequencer,
  composedMessageProcessor,
  scatterGather,
  routingSlip,
  processManager,
  messageBroker,
}

class RoutingPatternConfig {
  final RoutingPattern pattern;
  final RoutingPatternSettings? config;

  RoutingPatternConfig({required this.pattern, this.config});

  factory RoutingPatternConfig.fromJson(Map<String, dynamic> json) {
    return RoutingPatternConfig(
      pattern: _parseRoutingPattern(json['pattern']),
      config: json['config'] != null
          ? RoutingPatternSettings.fromJson(
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

  static RoutingPattern _parseRoutingPattern(dynamic value) {
    if (value is RoutingPattern) return value;
    final stringValue = value.toString();
    return RoutingPattern.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => RoutingPattern.contentBasedRouter,
    );
  }
}
