import 'package:flutter/material.dart';
import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';
import 'base_parser.dart';

class FlowchartParser with LayoutMixin implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.startsWith('graph') ||
        firstLine.startsWith('flowchart') ||
        _looksLikeFlowchart(lines);
  }

  bool _looksLikeFlowchart(List<String> lines) {
    final flowchartPatterns = [
      RegExp(r'\w+\s*-->?\s*\w+'),
      RegExp(r'\w+\s*\[[^\]]+\]'),
      RegExp(r'\w+\s*\([^)]+\)'),
    ];

    int flowchartLikeLines = 0;
    for (final line in lines.skip(1).take(5)) {
      for (final pattern in flowchartPatterns) {
        if (pattern.hasMatch(line)) {
          flowchartLikeLines++;
          break;
        }
      }
    }
    return flowchartLikeLines >= 2;
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final nodes = <String, DiagramNode>{};
    final edges = <DiagramEdge>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseLine(line, nodes, edges);
    }

    // Apply layout using the mixin method
    final nodeList = nodes.values.toList();
    if (nodeList.isNotEmpty) {
      layoutNodes(nodeList, edges);
    }

    return MermaidDiagram(
      type: DiagramType.flowchart,
      nodes: nodeList,
      edges: edges,
      rawCode: code,
    );
  }

  void _parseLine(
    String line,
    Map<String, DiagramNode> nodes,
    List<DiagramEdge> edges,
  ) {
    if (_parseEdge(line, nodes, edges)) return;
    _parseNode(line, nodes);
    _parseStyle(line, nodes);
  }

  bool _parseEdge(
    String line,
    Map<String, DiagramNode> nodes,
    List<DiagramEdge> edges,
  ) {
    final edgePatterns = [
      RegExp(
        r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>|<-->|<-\.->|<-=>)\s*(\w+)',
      ),
      RegExp(
        r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>)\s*\|\s*([^|]+)\s*\|\s*(\w+)',
      ),
      RegExp(r'(\w+)\s*(-->|--o|--x|---|-\.-|===|==>)\s*(\w+)\s*:\s*(.+)'),
    ];

    for (final pattern in edgePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final from = match.group(1)!;
        final arrow = match.group(2)!;
        final to = match.group(match.groupCount == 3 ? 3 : 4)!;
        final label = match.groupCount == 3 ? null : match.group(3);

        _ensureNodeExists(from, nodes);
        _ensureNodeExists(to, nodes);

        edges.add(_createEdge(from, to, arrow, label));
        return true;
      }
    }
    return false;
  }

  void _parseNode(String line, Map<String, DiagramNode> nodes) {
    final nodePatterns = [
      (RegExp(r'(\w+)\[([^\]]+)\]'), NodeShape.rectangle),
      (RegExp(r'(\w+)\(([^)]+)\)'), NodeShape.rounded),
      (RegExp(r'(\w+)\(\[([^\]]+)\]\)'), NodeShape.stadium),
      (RegExp(r'(\w+)\[\[([^\]]+)\]\]'), NodeShape.subroutine),
      (RegExp(r'(\w+)\[\(([^)]+)\)\]'), NodeShape.cylindrical),
      (RegExp(r'(\w+)\(\(([^)]+)\)\)'), NodeShape.circle),
      (RegExp(r'(\w+)>([^>]+)\]'), NodeShape.asymmetric),
      (RegExp(r'(\w+)\{([^}]+)\}'), NodeShape.rhombus),
      (RegExp(r'(\w+)\{\{([^}]+)\}\}'), NodeShape.hexagon),
      (RegExp(r'(\w+)\[\/([^\/]+)\/\]'), NodeShape.parallelogram),
      (RegExp(r'(\w+)\[\\([^\\]+)\\\]'), NodeShape.trapezoid),
      (RegExp(r'(\w+)\(\(\(([^)]+)\)\)\)'), NodeShape.doubleCircle),
    ];

    for (final pattern in nodePatterns) {
      final match = pattern.$1.firstMatch(line);
      if (match != null) {
        final id = match.group(1)!;
        final label = match.group(2)!;
        nodes[id] = DiagramNode(id: id, label: label, shape: pattern.$2);
        return;
      }
    }
  }

  void _parseStyle(String line, Map<String, DiagramNode> nodes) {
    final styleMatch = RegExp(
      r'style\s+(\w+)\s+fill:?#?(\w+),?stroke:?#?(\w+)',
    ).firstMatch(line);
    if (styleMatch != null) {
      final nodeId = styleMatch.group(1)!;
      final fillColor = styleMatch.group(2);
      final strokeColor = styleMatch.group(3);

      if (nodes.containsKey(nodeId)) {
        final node = nodes[nodeId]!;
        nodes[nodeId] = node.copyWith(
          fillColor: _parseColor(fillColor),
          strokeColor: _parseColor(strokeColor),
        );
      }
    }
  }

  DiagramEdge _createEdge(String from, String to, String arrow, String? label) {
    EdgeType edgeType = EdgeType.solid;
    if (arrow.contains('.')) edgeType = EdgeType.dotted;
    if (arrow.contains('==')) edgeType = EdgeType.thick;
    if (arrow.contains('x')) edgeType = EdgeType.cross;
    if (arrow.contains('o')) edgeType = EdgeType.circle;

    return DiagramEdge(
      from: from,
      to: to,
      label: label?.trim(),
      type: edgeType,
      bidirectional: arrow.contains('<') && arrow.contains('>'),
    );
  }

  void _ensureNodeExists(String nodeId, Map<String, DiagramNode> nodes) {
    if (!nodes.containsKey(nodeId)) {
      nodes[nodeId] = DiagramNode(id: nodeId, label: nodeId);
    }
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;

    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }

      switch (colorStr.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'teal':
          return Colors.teal;
        case 'cyan':
          return Colors.cyan;
        case 'amber':
          return Colors.amber;
        case 'grey':
          return Colors.grey;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}
