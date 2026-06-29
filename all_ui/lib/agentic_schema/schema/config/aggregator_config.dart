class AggregatorConfig {
  final String? correlationExpression;
  final int? completionSize;
  final int? completionTimeout;
  final String? aggregationStrategy;
  final bool? discardOnTimeout;

  AggregatorConfig({
    this.correlationExpression,
    this.completionSize = 10,
    this.completionTimeout = 30000,
    this.aggregationStrategy = 'default',
    this.discardOnTimeout = false,
  });

  factory AggregatorConfig.fromJson(Map<String, dynamic> json) {
    return AggregatorConfig(
      correlationExpression: json['correlationExpression'] as String?,
      completionSize: json['completionSize'] as int?,
      completionTimeout: json['completionTimeout'] as int?,
      aggregationStrategy: json['aggregationStrategy'] as String?,
      discardOnTimeout: json['discardOnTimeout'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (correlationExpression != null)
        'correlationExpression': correlationExpression,
      if (completionSize != null) 'completionSize': completionSize,
      if (completionTimeout != null) 'completionTimeout': completionTimeout,
      if (aggregationStrategy != null)
        'aggregationStrategy': aggregationStrategy,
      if (discardOnTimeout != null) 'discardOnTimeout': discardOnTimeout,
    };
  }
}
