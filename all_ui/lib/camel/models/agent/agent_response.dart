import 'execution_step.dart';

class AgentResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final List<ExecutionStep>? steps;
  final Map<String, dynamic>? metadata;
  final Duration? duration;

  AgentResponse({
    required this.success,
    this.data,
    this.error,
    this.steps,
    this.metadata,
    this.duration,
  });
}
