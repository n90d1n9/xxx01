// Undo/Redo Stack
import 'expression_node.dart';

class HistoryEntry {
  final ExpressionNode? node;
  final String script;
  final DateTime timestamp;

  HistoryEntry({
    required this.node,
    required this.script,
    required this.timestamp,
  });
}
