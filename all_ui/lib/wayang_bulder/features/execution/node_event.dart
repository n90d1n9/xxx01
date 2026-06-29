import 'model/execution_event.dart';

class NodeStartedEvent extends ExecutionEvent {
  final String nodeId;
  final String nodeName;
  NodeStartedEvent(this.nodeId, this.nodeName) : super('');
}
