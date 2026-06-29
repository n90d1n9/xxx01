import 'batch_trigger.dart';

class BatchProcessorNodeDefinition {
  final String id;
  final String name;
  final String description;
  final int batchSize;
  final Duration batchTimeout;
  final BatchTrigger trigger;
  final bool processPartialBatch; // Process partial batch on timeout
  final int maxQueueSize;
  final Map<String, dynamic> metadata;

  BatchProcessorNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.batchSize = 10,
    this.batchTimeout = const Duration(seconds: 30),
    this.trigger = BatchTrigger.both,
    this.processPartialBatch = true,
    this.maxQueueSize = 1000,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'batchSize': batchSize,
    'batchTimeout': batchTimeout.inMilliseconds,
    'trigger': trigger.name,
    'processPartialBatch': processPartialBatch,
    'maxQueueSize': maxQueueSize,
    'metadata': metadata,
  };

  factory BatchProcessorNodeDefinition.fromJson(Map<String, dynamic> json) =>
      BatchProcessorNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        batchSize: json['batchSize'] ?? 10,
        batchTimeout: Duration(milliseconds: json['batchTimeout'] ?? 30000),
        trigger: BatchTrigger.values.firstWhere(
          (e) => e.name == json['trigger'],
          orElse: () => BatchTrigger.both,
        ),
        processPartialBatch: json['processPartialBatch'] ?? true,
        maxQueueSize: json['maxQueueSize'] ?? 1000,
        metadata: json['metadata'] ?? {},
      );
}
