import 'cache_strategy.dart';

class CacheNodeDefinition {
  final String id;
  final String name;
  final String description;
  final CacheStrategy strategy;
  final Duration ttl;
  final int maxSize;
  final String cacheKeyField; // Field to use as cache key
  final bool cacheOnError; // Cache even if operation fails
  final Map<String, dynamic> metadata;

  CacheNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.strategy = CacheStrategy.timeToLive,
    this.ttl = const Duration(minutes: 5),
    this.maxSize = 100,
    this.cacheKeyField = 'id',
    this.cacheOnError = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'strategy': strategy.name,
    'ttl': ttl.inMilliseconds,
    'maxSize': maxSize,
    'cacheKeyField': cacheKeyField,
    'cacheOnError': cacheOnError,
    'metadata': metadata,
  };

  factory CacheNodeDefinition.fromJson(Map<String, dynamic> json) =>
      CacheNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        strategy: CacheStrategy.values.firstWhere(
          (e) => e.name == json['strategy'],
          orElse: () => CacheStrategy.timeToLive,
        ),
        ttl: Duration(milliseconds: json['ttl'] ?? 300000),
        maxSize: json['maxSize'] ?? 100,
        cacheKeyField: json['cacheKeyField'] ?? 'id',
        cacheOnError: json['cacheOnError'] ?? false,
        metadata: json['metadata'] ?? {},
      );
}
