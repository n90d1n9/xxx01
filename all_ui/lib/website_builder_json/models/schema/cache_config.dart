class CacheConfig {
  final bool enabled;
  final int ttl; // Time to live in seconds
  final String strategy; // memory, localStorage, sessionStorage

  CacheConfig({
    required this.enabled,
    required this.ttl,
    required this.strategy,
  });

  factory CacheConfig.fromJson(Map<String, dynamic> json) {
    return CacheConfig(
      enabled: json['enabled'] as bool,
      ttl: json['ttl'] as int,
      strategy: json['strategy'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'ttl': ttl,
    'strategy': strategy,
  };
}
