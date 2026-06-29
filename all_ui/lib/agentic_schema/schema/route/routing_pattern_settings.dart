import 'routing_rule.dart';

class RoutingPatternSettings {
  final List<RoutingRule>? rules;
  final String? defaultRoute;
  final bool? parallelProcessing;
  final String? aggregationStrategy;
  final int? completionSize;
  final int? completionTimeout;
  final String? correlationExpression;

  RoutingPatternSettings({
    this.rules,
    this.defaultRoute,
    this.parallelProcessing,
    this.aggregationStrategy,
    this.completionSize,
    this.completionTimeout,
    this.correlationExpression,
  });

  factory RoutingPatternSettings.fromJson(Map<String, dynamic> json) {
    return RoutingPatternSettings(
      rules: json['rules'] != null
          ? (json['rules'] as List)
                .map((e) => RoutingRule.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      defaultRoute: json['defaultRoute'] as String?,
      parallelProcessing: json['parallelProcessing'] as bool?,
      aggregationStrategy: json['aggregationStrategy'] as String?,
      completionSize: json['completionSize'] as int?,
      completionTimeout: json['completionTimeout'] as int?,
      correlationExpression: json['correlationExpression'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (rules != null) 'rules': rules!.map((e) => e.toJson()).toList(),
      if (defaultRoute != null) 'defaultRoute': defaultRoute,
      if (parallelProcessing != null) 'parallelProcessing': parallelProcessing,
      if (aggregationStrategy != null)
        'aggregationStrategy': aggregationStrategy,
      if (completionSize != null) 'completionSize': completionSize,
      if (completionTimeout != null) 'completionTimeout': completionTimeout,
      if (correlationExpression != null)
        'correlationExpression': correlationExpression,
    };
  }
}
