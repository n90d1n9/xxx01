class LazyLoading {
  final bool enabled;
  final List<String> componentTypes; // Which component types to lazy load
  final String strategy; // viewport, interaction, eager

  LazyLoading({
    required this.enabled,
    required this.componentTypes,
    required this.strategy,
  });

  factory LazyLoading.fromJson(Map<String, dynamic> json) {
    return LazyLoading(
      enabled: json['enabled'] as bool,
      componentTypes: List<String>.from(json['componentTypes'] as List),
      strategy: json['strategy'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'componentTypes': componentTypes,
    'strategy': strategy,
  };
}
