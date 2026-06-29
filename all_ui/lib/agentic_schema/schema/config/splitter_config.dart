class SplitterConfig {
  final String strategy;
  final String? expression;
  final bool? streaming;
  final bool? parallelProcessing;

  SplitterConfig({
    required this.strategy,
    this.expression,
    this.streaming = false,
    this.parallelProcessing = false,
  });

  factory SplitterConfig.fromJson(Map<String, dynamic> json) {
    return SplitterConfig(
      strategy: json['strategy'] as String,
      expression: json['expression'] as String?,
      streaming: json['streaming'] as bool?,
      parallelProcessing: json['parallelProcessing'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      if (expression != null) 'expression': expression,
      if (streaming != null) 'streaming': streaming,
      if (parallelProcessing != null) 'parallelProcessing': parallelProcessing,
    };
  }
}
