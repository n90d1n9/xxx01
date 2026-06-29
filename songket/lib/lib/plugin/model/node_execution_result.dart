import '../../execution/model/execution_event.dart';

class NodeExecutionResult {
  final String nodeId;
  final ExecutionStatus status;
  final Map<String, dynamic> outputs; // ✅ primary output data per port
  final Duration duration;
  final String? error;

  // Optional metadata for debugging, tracing, etc.
  final Map<String, dynamic>? metadata;

  // Private constructor to enforce consistency
  NodeExecutionResult._({
    required this.nodeId,
    required this.status,
    required this.outputs,
    required this.duration,
    this.error,
    this.metadata,
  });

  // Success factory
  factory NodeExecutionResult.success({
    required String nodeId,
    required Map<String, dynamic> outputs,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    return NodeExecutionResult._(
      nodeId: nodeId,
      status: ExecutionStatus.success,
      outputs: outputs,
      duration: duration,
      metadata: metadata,
    );
  }

  // Failure factory
  factory NodeExecutionResult.failure({
    required String nodeId,
    required String error,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    return NodeExecutionResult._(
      nodeId: nodeId,
      status: ExecutionStatus.failed,
      outputs: const {},
      duration: duration,
      error: error,
      metadata: metadata,
    );
  }
}

enum ExecutionMode { normal, test, debug, dryRun }
