class CircuitBreaker {
  final bool? enabled;
  final int? failureThreshold;
  final int? successThreshold;
  final int? timeout;
  final int? halfOpenRequests;

  CircuitBreaker({
    this.enabled = true,
    this.failureThreshold = 5,
    this.successThreshold = 3,
    this.timeout = 30000,
    this.halfOpenRequests = 2,
  });

  factory CircuitBreaker.fromJson(Map<String, dynamic> json) {
    return CircuitBreaker(
      enabled: json['enabled'] as bool?,
      failureThreshold: json['failureThreshold'] as int?,
      successThreshold: json['successThreshold'] as int?,
      timeout: json['timeout'] as int?,
      halfOpenRequests: json['halfOpenRequests'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (failureThreshold != null) 'failureThreshold': failureThreshold,
      if (successThreshold != null) 'successThreshold': successThreshold,
      if (timeout != null) 'timeout': timeout,
      if (halfOpenRequests != null) 'halfOpenRequests': halfOpenRequests,
    };
  }
}
