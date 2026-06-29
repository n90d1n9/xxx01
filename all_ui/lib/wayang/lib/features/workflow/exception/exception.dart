import '../../execution/model/execution_event.dart';
import '../../execution/node_complete_event.dart';
import '../../execution/node_event.dart';
import '../../execution/node_failed_event.dart';

class LoggingExecutionListener implements ExecutionListener {
  final List<String> logs = [];

  @override
  void onEvent(ExecutionEvent event) {
    if (event is ExecutionStartedEvent) {
      logs.add('[${event.timestamp}] Execution started: ${event.executionId}');
    } else if (event is ExecutionCompletedEvent) {
      logs.add(
        '[${event.timestamp}] Execution completed: ${event.executionId}',
      );
    } else if (event is ExecutionFailedEvent) {
      logs.add('[${event.timestamp}] Execution failed: ${event.error}');
    } else if (event is NodeStartedEvent) {
      logs.add('[${event.timestamp}] Node started: ${event.nodeName}');
    } else if (event is NodeCompletedEvent) {
      logs.add('[${event.timestamp}] Node completed: ${event.result.nodeId}');
    } else if (event is NodeFailedEvent) {
      logs.add('[${event.timestamp}] Node failed: ${event.error}');
    }
  }

  void printLogs() {
    for (final log in logs) {
      print(log);
    }
  }
}
