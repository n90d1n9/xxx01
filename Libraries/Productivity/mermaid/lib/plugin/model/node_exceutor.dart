import 'node_execution_context.dart';
import 'node_execution_result.dart';
import 'node_schema.dart';

class NodeExecutor {
  String get nodeType => '';
  NodeSchema get schema => throw UnimplementedError();
  Future<NodeExecutionResult> execute(NodeExecutionContext context) async {
    throw UnimplementedError();
  }
}
