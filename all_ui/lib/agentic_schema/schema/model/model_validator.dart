import '../agent/agent.dart';
import '../node/node_type.dart';
import '../workflow/workflow.dart';

class ModelValidator {
  static String? validateWorkflow(Workflow workflow) {
    if (workflow.nodes.isEmpty) {
      return 'Workflow must have at least one node';
    }

    final startNodes = workflow.nodes.where((n) => n.type == NodeType.start);
    if (startNodes.isEmpty) {
      return 'Workflow must have a start node';
    }
    if (startNodes.length > 1) {
      return 'Workflow can only have one start node';
    }

    // Check for orphaned nodes
    final nodeIds = workflow.nodes.map((n) => n.id).toSet();
    final edges = workflow.edges ?? [];
    final connectedNodes = <String>{};
    for (final edge in edges) {
      connectedNodes.add(edge.source);
      connectedNodes.add(edge.target);
    }

    final orphanedNodes = nodeIds.difference(connectedNodes);
    if (orphanedNodes.isNotEmpty && orphanedNodes.length < nodeIds.length) {
      return 'Workflow has disconnected nodes';
    }

    return null;
  }

  static String? validateAgent(Agent agent) {
    if (agent.name.trim().isEmpty) {
      return 'Agent name cannot be empty';
    }

    if (agent.workflows != null) {
      for (final workflow in agent.workflows!) {
        final error = validateWorkflow(workflow);
        if (error != null) {
          return 'Workflow "${workflow.name}": $error';
        }
      }
    }

    return null;
  }
}
