class RetryConfig {
  final int maxRetries;
  final String backoffStrategy; // linear, exponential
  final int initialDelay; // milliseconds

  RetryConfig({
    required this.maxRetries,
    required this.backoffStrategy,
    required this.initialDelay,
  });

  factory RetryConfig.fromJson(Map<String, dynamic> json) {
    return RetryConfig(
      maxRetries: json['maxRetries'] as int,
      backoffStrategy: json['backoffStrategy'] as String,
      initialDelay: json['initialDelay'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'maxRetries': maxRetries,
    'backoffStrategy': backoffStrategy,
    'initialDelay': initialDelay,
  };
}
