class TransactionConfig {
  final String? transactionManager;
  final String? propagation;
  final String? isolation;
  final int? timeout;
  final List<String>? rollbackOn;

  TransactionConfig({
    this.transactionManager,
    this.propagation = 'required',
    this.isolation = 'default',
    this.timeout = 30000,
    this.rollbackOn,
  });

  factory TransactionConfig.fromJson(Map<String, dynamic> json) {
    return TransactionConfig(
      transactionManager: json['transactionManager'] as String?,
      propagation: json['propagation'] as String?,
      isolation: json['isolation'] as String?,
      timeout: json['timeout'] as int?,
      rollbackOn: json['rollbackOn'] != null
          ? List<String>.from(json['rollbackOn'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (transactionManager != null) 'transactionManager': transactionManager,
      if (propagation != null) 'propagation': propagation,
      if (isolation != null) 'isolation': isolation,
      if (timeout != null) 'timeout': timeout,
      if (rollbackOn != null) 'rollbackOn': rollbackOn,
    };
  }
}
