import '../agent/agent.dart';
import '../common/metadata.dart';
import '../common/position.dart';
import '../node/node_type.dart';
import '../workflow/workflow.dart';
import '../workflow/workflow_edge.dart';
import '../workflow/workflow_node.dart';
import 'llm_config.dart';

class ModelFactory {
  static WorkflowNode createNode({
    required NodeType type,
    required String name,
    required Position position,
    String? description,
  }) {
    return WorkflowNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      name: name,
      description: description,
      position: position,
      category: type.category,
      metadata: Metadata(
        createdAt: DateTime.now(),
        color: '#${type.color.value.toRadixString(16).substring(2)}',
      ),
    );
  }

  static WorkflowEdge createEdge({
    required String source,
    required String target,
    String? label,
    EdgeType? type,
  }) {
    return WorkflowEdge(
      id: '${source}_${target}_${DateTime.now().millisecondsSinceEpoch}',
      source: source,
      target: target,
      label: label,
      type: type ?? EdgeType.defaultType,
      animated: true,
    );
  }

  static Agent createAgent({
    required String name,
    required AgentType type,
    required LLMProvider provider,
    required String model,
  }) {
    return Agent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      status: AgentStatus.draft,
      llmConfig: LLMConfig(provider: provider, model: model),
      metadata: Metadata(createdAt: DateTime.now()),
    );
  }

  static Workflow createWorkflow({required String name, String? description}) {
    final startNode = createNode(
      type: NodeType.start,
      name: 'Start',
      position: Position(x: 100, y: 100),
    );

    return Workflow(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: WorkflowType.sequential,
      nodes: [startNode],
      edges: [],
      metadata: Metadata(createdAt: DateTime.now()),
    );
  }
}
