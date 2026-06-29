class RetryConfig {
  final int? maxRetries;
  final double? backoffMultiplier;
  final int? timeout;

  RetryConfig({
    this.maxRetries = 3,
    this.backoffMultiplier = 2.0,
    this.timeout = 30000,
  });

  factory RetryConfig.fromJson(Map<String, dynamic> json) {
    return RetryConfig(
      maxRetries: json['maxRetries'] as int?,
      backoffMultiplier: json['backoffMultiplier'] != null
          ? (json['backoffMultiplier'] as num).toDouble()
          : null,
      timeout: json['timeout'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxRetries != null) 'maxRetries': maxRetries,
      if (backoffMultiplier != null) 'backoffMultiplier': backoffMultiplier,
      if (timeout != null) 'timeout': timeout,
    };
  }
}
