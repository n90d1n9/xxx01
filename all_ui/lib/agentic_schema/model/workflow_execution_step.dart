import 'execution_step.dart';

class WorkflowExecutionState {
  final bool isRunning;
  final String? currentNodeId;
  final Map<String, dynamic> executionData;
  final List<ExecutionStep> executionHistory;
  final String? error;
  final double progress;

  WorkflowExecutionState({
    this.isRunning = false,
    this.currentNodeId,
    this.executionData = const {},
    this.executionHistory = const [],
    this.error,
    this.progress = 0.0,
  });

  WorkflowExecutionState copyWith({
    bool? isRunning,
    String? currentNodeId,
    Map<String, dynamic>? executionData,
    List<ExecutionStep>? executionHistory,
    String? error,
    double? progress,
  }) {
    return WorkflowExecutionState(
      isRunning: isRunning ?? this.isRunning,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      executionData: executionData ?? this.executionData,
      executionHistory: executionHistory ?? this.executionHistory,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}
