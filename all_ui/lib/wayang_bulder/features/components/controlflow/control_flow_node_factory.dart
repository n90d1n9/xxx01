import '../ifelse/model/ifelse_node_definition.dart';
import '../ifelse/utils/ifelse_node_execution.dart';
import '../whileloop/while_loop_node_definition.dart';
import '../whileloop/while_node_node_executor.dart';

class ControlFlowNodeFactory {
  static dynamic createExecutor(
    String nodeType,
    Map<String, dynamic> definition,
  ) {
    switch (nodeType) {
      case 'if_else':
        return IfElseNodeExecutor(IfElseNodeDefinition.fromJson(definition));
      case 'while_loop':
        return WhileLoopNodeExecutor(
          WhileLoopNodeDefinition.fromJson(definition),
        );
      default:
        throw Exception('Unknown control flow node type: $nodeType');
    }
  }
}
