class LoadBalancerConfig {
  final String strategy;
  final Map<String, dynamic>? weights;

  LoadBalancerConfig({required this.strategy, this.weights});

  factory LoadBalancerConfig.fromJson(Map<String, dynamic> json) {
    return LoadBalancerConfig(
      strategy: json['strategy'] as String,
      weights: json['weights'] != null
          ? Map<String, dynamic>.from(json['weights'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'strategy': strategy, if (weights != null) 'weights': weights};
  }
}
