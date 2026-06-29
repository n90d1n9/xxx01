import '../schema/workflow/workflow.dart';
import '../schema/workflow/workflow_node.dart';

class WorkflowSearchResult {
  final Workflow workflow;
  final List<WorkflowNode> matchingNodes;
  final double relevance;

  WorkflowSearchResult({
    required this.workflow,
    required this.matchingNodes,
    required this.relevance,
  });
}
