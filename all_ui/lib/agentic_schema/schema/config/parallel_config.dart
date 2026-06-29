class ParallelConfig {
  final int? maxConcurrency;
  final bool? waitForAll;
  final String? aggregationStrategy;
  final String? executorService;

  ParallelConfig({
    this.maxConcurrency = 5,
    this.waitForAll = true,
    this.aggregationStrategy,
    this.executorService,
  });

  factory ParallelConfig.fromJson(Map<String, dynamic> json) {
    return ParallelConfig(
      maxConcurrency: json['maxConcurrency'] as int?,
      waitForAll: json['waitForAll'] as bool?,
      aggregationStrategy: json['aggregationStrategy'] as String?,
      executorService: json['executorService'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxConcurrency != null) 'maxConcurrency': maxConcurrency,
      if (waitForAll != null) 'waitForAll': waitForAll,
      if (aggregationStrategy != null)
        'aggregationStrategy': aggregationStrategy,
      if (executorService != null) 'executorService': executorService,
    };
  }
}
