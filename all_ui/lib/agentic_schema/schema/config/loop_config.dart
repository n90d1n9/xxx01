class LoopConfig {
  final int? maxIterations;
  final String? breakCondition;
  final String? iterateOver;

  LoopConfig({this.maxIterations = 100, this.breakCondition, this.iterateOver});

  factory LoopConfig.fromJson(Map<String, dynamic> json) {
    return LoopConfig(
      maxIterations: json['maxIterations'] as int?,
      breakCondition: json['breakCondition'] as String?,
      iterateOver: json['iterateOver'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxIterations != null) 'maxIterations': maxIterations,
      if (breakCondition != null) 'breakCondition': breakCondition,
      if (iterateOver != null) 'iterateOver': iterateOver,
    };
  }
}
