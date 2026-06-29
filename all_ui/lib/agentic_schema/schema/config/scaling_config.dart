class ScalingConfig {
  final int? minInstances;
  final int? maxInstances;
  final bool? autoscale;
  final double? targetCPU;
  final double? targetMemory;

  ScalingConfig({
    this.minInstances = 1,
    this.maxInstances = 10,
    this.autoscale = false,
    this.targetCPU = 0.8,
    this.targetMemory = 0.8,
  });

  factory ScalingConfig.fromJson(Map<String, dynamic> json) {
    return ScalingConfig(
      minInstances: json['minInstances'] as int?,
      maxInstances: json['maxInstances'] as int?,
      autoscale: json['autoscale'] as bool?,
      targetCPU: json['targetCPU'] != null
          ? (json['targetCPU'] as num).toDouble()
          : null,
      targetMemory: json['targetMemory'] != null
          ? (json['targetMemory'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (minInstances != null) 'minInstances': minInstances,
      if (maxInstances != null) 'maxInstances': maxInstances,
      if (autoscale != null) 'autoscale': autoscale,
      if (targetCPU != null) 'targetCPU': targetCPU,
      if (targetMemory != null) 'targetMemory': targetMemory,
    };
  }
}
