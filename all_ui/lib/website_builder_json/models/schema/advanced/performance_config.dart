import 'cache_strategy.dart';
import 'compression_config.dart';

class PerformanceConfig {
  final bool imageOptimization;
  final bool codeSplitting;
  final bool prefetching;
  final CacheStrategy? cacheStrategy;
  final CompressionConfig? compression;

  PerformanceConfig({
    this.imageOptimization = true,
    this.codeSplitting = true,
    this.prefetching = true,
    this.cacheStrategy,
    this.compression,
  });

  factory PerformanceConfig.fromJson(Map<String, dynamic> json) {
    return PerformanceConfig(
      imageOptimization: json['imageOptimization'] as bool? ?? true,
      codeSplitting: json['codeSplitting'] as bool? ?? true,
      prefetching: json['prefetching'] as bool? ?? true,
      cacheStrategy:
          json['cacheStrategy'] != null
              ? CacheStrategy.fromJson(
                json['cacheStrategy'] as Map<String, dynamic>,
              )
              : null,
      compression:
          json['compression'] != null
              ? CompressionConfig.fromJson(
                json['compression'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'imageOptimization': imageOptimization,
    'codeSplitting': codeSplitting,
    'prefetching': prefetching,
    if (cacheStrategy != null) 'cacheStrategy': cacheStrategy!.toJson(),
    if (compression != null) 'compression': compression!.toJson(),
  };
}
