class RedeliveryPolicy {
  final int? maximumRedeliveries;
  final int? redeliveryDelay;
  final double? backOffMultiplier;
  final bool? useExponentialBackOff;

  RedeliveryPolicy({
    this.maximumRedeliveries = 3,
    this.redeliveryDelay = 1000,
    this.backOffMultiplier = 2.0,
    this.useExponentialBackOff = true,
  });

  factory RedeliveryPolicy.fromJson(Map<String, dynamic> json) {
    return RedeliveryPolicy(
      maximumRedeliveries: json['maximumRedeliveries'] as int?,
      redeliveryDelay: json['redeliveryDelay'] as int?,
      backOffMultiplier: json['backOffMultiplier'] != null
          ? (json['backOffMultiplier'] as num).toDouble()
          : null,
      useExponentialBackOff: json['useExponentialBackOff'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maximumRedeliveries != null)
        'maximumRedeliveries': maximumRedeliveries,
      if (redeliveryDelay != null) 'redeliveryDelay': redeliveryDelay,
      if (backOffMultiplier != null) 'backOffMultiplier': backOffMultiplier,
      if (useExponentialBackOff != null)
        'useExponentialBackOff': useExponentialBackOff,
    };
  }
}
