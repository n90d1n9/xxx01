import 'edge_diff.dart';
import 'node_diff.dart';

class WorkflowDiff {
  final List<NodeDiff> nodeDiffs;
  final List<EdgeDiff> edgeDiffs;

  WorkflowDiff({required this.nodeDiffs, required this.edgeDiffs});
}
