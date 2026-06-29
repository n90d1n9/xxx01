import 'model/execution_event.dart';
import 'model/node_execution_result.dart';

class NodeCompletedEvent extends ExecutionEvent {
  final String nodeId;
  final NodeExecutionResult result;
  NodeCompletedEvent(this.nodeId, this.result) : super('');
}
