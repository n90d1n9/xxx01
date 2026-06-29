import 'retry_strategy.dart';

class TryCatchFinallyNodeDefinition {
  final String id;
  final String name;
  final String description;
  final int maxRetries;
  final RetryStrategy retryStrategy;
  final Duration retryDelay;
  final double backoffMultiplier;
  final bool executeFinallyOnError;
  final List<String> catchableErrors; // Empty means catch all
  final Map<String, dynamic> metadata;

  TryCatchFinallyNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.maxRetries = 3,
    this.retryStrategy = RetryStrategy.exponentialBackoff,
    this.retryDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.executeFinallyOnError = true,
    this.catchableErrors = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'maxRetries': maxRetries,
    'retryStrategy': retryStrategy.name,
    'retryDelay': retryDelay.inMilliseconds,
    'backoffMultiplier': backoffMultiplier,
    'executeFinallyOnError': executeFinallyOnError,
    'catchableErrors': catchableErrors,
    'metadata': metadata,
  };

  factory TryCatchFinallyNodeDefinition.fromJson(Map<String, dynamic> json) =>
      TryCatchFinallyNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        maxRetries: json['maxRetries'] ?? 3,
        retryStrategy: RetryStrategy.values.firstWhere(
          (e) => e.name == json['retryStrategy'],
          orElse: () => RetryStrategy.exponentialBackoff,
        ),
        retryDelay: Duration(milliseconds: json['retryDelay'] ?? 1000),
        backoffMultiplier: json['backoffMultiplier'] ?? 2.0,
        executeFinallyOnError: json['executeFinallyOnError'] ?? true,
        catchableErrors:
            (json['catchableErrors'] as List?)?.cast<String>() ?? [],
        metadata: json['metadata'] ?? {},
      );
}
