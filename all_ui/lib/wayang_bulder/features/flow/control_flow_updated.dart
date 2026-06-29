import '../components/ifelse/model/ifelse_node_definition.dart';
import '../components/ifelse/utils/ifelse_node_execution.dart';
import '../components/whileloop/while_loop_node_definition.dart';
import '../components/whileloop/while_node_node_executor.dart';
import 'human/human_executor.dart';
import 'human/model/human_loop_definition.dart';

class ControlFlowNodeFactoryUpdated {
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
      case 'human_in_loop':
        return HumanInLoopNodeExecutor(
          HumanInLoopNodeDefinition.fromJson(definition),
        );
      default:
        throw Exception('Unknown control flow node type: $nodeType');
    }
  }
}
