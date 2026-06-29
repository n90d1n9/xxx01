import '../../schema/workflow/workflow_node.dart';
import 'edge_diff.dart';

class NodeDiff {
  final WorkflowNode? oldNode;
  final WorkflowNode? newNode;
  final DiffType type;
  final Map<String, dynamic> changes;

  NodeDiff({
    this.oldNode,
    this.newNode,
    required this.type,
    required this.changes,
  });
}
