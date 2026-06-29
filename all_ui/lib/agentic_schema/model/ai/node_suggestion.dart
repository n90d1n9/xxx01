import '../../schema/node/node_type.dart';

class NodeSuggestion {
  final NodeType type;
  final String reason;
  final double confidence;

  NodeSuggestion({
    required this.type,
    required this.reason,
    required this.confidence,
  });
}
