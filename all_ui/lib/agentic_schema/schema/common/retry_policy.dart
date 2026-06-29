class RetryPolicy {
  final int? maxAttempts;
  final String? backoffStrategy;
  final int? initialDelay;
  final int? maxDelay;
  final double? multiplier;

  RetryPolicy({
    this.maxAttempts = 3,
    this.backoffStrategy = 'exponential',
    this.initialDelay = 1000,
    this.maxDelay = 30000,
    this.multiplier = 2.0,
  });

  factory RetryPolicy.fromJson(Map<String, dynamic> json) {
    return RetryPolicy(
      maxAttempts: json['maxAttempts'] as int?,
      backoffStrategy: json['backoffStrategy'] as String?,
      initialDelay: json['initialDelay'] as int?,
      maxDelay: json['maxDelay'] as int?,
      multiplier: json['multiplier'] != null
          ? (json['multiplier'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxAttempts != null) 'maxAttempts': maxAttempts,
      if (backoffStrategy != null) 'backoffStrategy': backoffStrategy,
      if (initialDelay != null) 'initialDelay': initialDelay,
      if (maxDelay != null) 'maxDelay': maxDelay,
      if (multiplier != null) 'multiplier': multiplier,
    };
  }
}
