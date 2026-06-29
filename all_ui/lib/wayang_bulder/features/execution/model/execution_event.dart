import '../node_event.dart';
import '../node_complete_event.dart';
import '../node_failed_event.dart';
import 'execution_result.dart';
import 'node_execution_result.dart';

abstract class ExecutionListener {
  void onEvent(ExecutionEvent event);
}

abstract class ExecutionEvent {
  final String executionId;
  final DateTime timestamp;

  ExecutionEvent(this.executionId) : timestamp = DateTime.now();

  factory ExecutionEvent.started(String executionId) = ExecutionStartedEvent;
  factory ExecutionEvent.completed(String executionId, ExecutionResult result) =
      ExecutionCompletedEvent;
  factory ExecutionEvent.failed(String executionId, String error) =
      ExecutionFailedEvent;
  factory ExecutionEvent.nodeStarted(String nodeId, String nodeName) =
      NodeStartedEvent;
  factory ExecutionEvent.nodeCompleted(
    String nodeId,
    NodeExecutionResult result,
  ) = NodeCompletedEvent;
  factory ExecutionEvent.nodeFailed(String nodeId, String error) =
      NodeFailedEvent;
}

enum ExecutionStatus { pending, running, success, failed, cancelled, timeout }

class ExecutionStartedEvent extends ExecutionEvent {
  ExecutionStartedEvent(super.executionId);
}

class ExecutionCompletedEvent extends ExecutionEvent {
  final ExecutionResult result;
  ExecutionCompletedEvent(super.executionId, this.result);
}

class ExecutionFailedEvent extends ExecutionEvent {
  final String error;
  ExecutionFailedEvent(super.executionId, this.error);
}
