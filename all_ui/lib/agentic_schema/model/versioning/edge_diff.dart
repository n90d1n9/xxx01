import '../../schema/workflow/workflow_edge.dart';

enum DiffType { added, removed, modified, unchanged }

class EdgeDiff {
  final WorkflowEdge? oldEdge;
  final WorkflowEdge? newEdge;
  final DiffType type;

  EdgeDiff({this.oldEdge, this.newEdge, required this.type});
}
