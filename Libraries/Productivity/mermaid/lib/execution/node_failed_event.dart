import 'model/execution_event.dart';

class NodeFailedEvent extends ExecutionEvent {
  final String nodeId;
  final String error;
  NodeFailedEvent(this.nodeId, this.error) : super('');
}
