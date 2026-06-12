import 'package:flutter/material.dart';

import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';
import 'base_parser.dart';

class QuadrantParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('quadrant');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final nodes = <DiagramNode>[];
    final quadrantTitles = <String>['', '', '', ''];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (_parseQuadrantTitle(line, quadrantTitles)) continue;
      _parseDataPoint(line, nodes);
    }

    return MermaidDiagram(
      type: DiagramType.quadrant,
      nodes: nodes,
      rawCode: code,
    );
  }

  bool _parseQuadrantTitle(String line, List<String> quadrantTitles) {
    final match = RegExp(r'quadrant\s*(\d)\s*:\s*(.+)').firstMatch(line);
    if (match != null) {
      final quadrant = int.parse(match.group(1)!);
      final title = match.group(2)!;
      if (quadrant >= 1 && quadrant <= 4) {
        quadrantTitles[quadrant - 1] = title;
      }
      return true;
    }
    return false;
  }

  void _parseDataPoint(String line, List<DiagramNode> nodes) {
    final match = RegExp(
      r'([^:]+):\s*\[(\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?)\]',
    ).firstMatch(line);
    if (match != null) {
      final label = match.group(1)!.trim();
      final x = double.parse(match.group(2)!);
      final y = double.parse(match.group(3)!);

      nodes.add(
        DiagramNode(
          id: 'point_${nodes.length}',
          label: label,
          shape: NodeShape.circle,
          position: Offset(x * 100 + 200, 400 - y * 100),
        ),
      );
    }
  }
}
