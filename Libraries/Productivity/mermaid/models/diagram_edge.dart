import 'diagram_type.dart';

class DiagramEdge {
  final String from;
  final String to;
  final String? label;
  final EdgeType type;
  final bool bidirectional;

  DiagramEdge({
    required this.from,
    required this.to,
    this.label,
    this.type = EdgeType.solid,
    this.bidirectional = false,
  });
}
