import 'execution_step.dart';
import 'orchestrator_agent.dart';

class ExecutionPlan {
  final List<String> agentIds;
  final OrchestrationType strategy;
  final Duration? estimatedDuration;
  final Map<String, dynamic>? metadata;
  final List<ExecutionStep> steps;

  ExecutionPlan({
    required this.agentIds,
    required this.strategy,
    this.estimatedDuration,
    this.metadata,
    this.steps = const [],
  });

  factory ExecutionPlan.fromJson(Map<String, dynamic> json) {
    final agentIds = List<String>.from(json['agentIds'] as List);
    final strategy = OrchestrationType.values.firstWhere(
      (e) => e.name == json['strategy'] as String,
    );
    final estimatedDurationJson = json['estimatedDuration'] as int?;
    final estimatedDuration =
        estimatedDurationJson != null
            ? Duration(milliseconds: estimatedDurationJson)
            : null;
    final metadata = json['metadata'] as Map<String, dynamic>? ?? null;
    final steps =
        (json['steps'] as List?)
            ?.map((e) => ExecutionStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return ExecutionPlan(
      agentIds: agentIds,
      strategy: strategy,
      estimatedDuration: estimatedDuration,
      metadata: metadata,
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentIds': agentIds,
      'strategy': strategy.name,
      'estimatedDuration':
          estimatedDuration?.inMilliseconds, // serializing Duration as ms
      'metadata': metadata,
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }

  ExecutionPlan copyWith({
    List<String>? agentIds,
    OrchestrationType? strategy,
    Duration? estimatedDuration,
    Map<String, dynamic>? metadata,
    List<ExecutionStep>? steps,
  }) {
    return ExecutionPlan(
      agentIds: agentIds ?? this.agentIds,
      strategy: strategy ?? this.strategy,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      metadata: metadata ?? this.metadata,
      steps: steps ?? this.steps,
    );
  }
}
