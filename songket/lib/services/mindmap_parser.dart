import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';
import 'base_parser.dart';

class MindmapParser with LayoutMixin implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('mindmap');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final nodes = <DiagramNode>[];
    final edges = <DiagramEdge>[];
    final nodeMap = <String, DiagramNode>{};
    var rootId = '';

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      _parseNode(line, nodes, edges, nodeMap, i == 1 ? null : nodes.last.id);
    }

    // Find root node (first node)
    if (nodes.isNotEmpty) {
      rootId = nodes.first.id;
      _layoutMindmap(nodes, edges, rootId);
    }

    return MermaidDiagram(
      type: DiagramType.mindmap,
      nodes: nodes,
      edges: edges,
      rawCode: code,
    );
  }

  void _parseNode(
    String line,
    List<DiagramNode> nodes,
    List<DiagramEdge> edges,
    Map<String, DiagramNode> nodeMap,
    String? parentId,
  ) {
    // Count leading asterisks to determine level
    final level = line.split('').takeWhile((c) => c == '*').length;
    final content = line.substring(level).trim();

    if (content.isEmpty) return;

    final nodeId = 'node_${nodes.length}';
    final node = DiagramNode(
      id: nodeId,
      label: content,
      shape: level == 1 ? NodeShape.ellipse : NodeShape.rectangle,
    );

    nodes.add(node);
    nodeMap[nodeId] = node;

    // Create edge if this is not the root node
    if (parentId != null) {
      edges.add(DiagramEdge(from: parentId, to: nodeId, type: EdgeType.solid));
    }
  }

  void _layoutMindmap(
    List<DiagramNode> nodes,
    List<DiagramEdge> edges,
    String rootId,
  ) {
    if (nodes.isEmpty) return;

    // Position root node in center
    final rootNode = nodes.firstWhere((n) => n.id == rootId);
    rootNode.copyWith(position: const Offset(400, 300));

    // Build children map
    final children = <String, List<String>>{};
    for (final edge in edges) {
      children.putIfAbsent(edge.from, () => []).add(edge.to);
    }

    // Layout children recursively
    _layoutMindmapChildren(rootId, children, nodes, 1, -math.pi / 2, math.pi);
  }

  void _layoutMindmapChildren(
    String nodeId,
    Map<String, List<String>> children,
    List<DiagramNode> nodes,
    int level,
    double startAngle,
    double angleRange,
  ) {
    final childIds = children[nodeId] ?? [];
    if (childIds.isEmpty) return;

    final angleStep = angleRange / math.max(1, childIds.length - 1);
    final parentNode = nodes.firstWhere((n) => n.id == nodeId);
    final radius = 120.0 + level * 80;

    for (var i = 0; i < childIds.length; i++) {
      final childNode = nodes.firstWhere((n) => n.id == childIds[i]);
      final angle = startAngle - angleRange / 2 + angleStep * i;

      childNode.copyWith(
        position: Offset(
          parentNode.position.dx + radius * math.cos(angle),
          parentNode.position.dy + radius * math.sin(angle),
        ),
      );

      _layoutMindmapChildren(
        childIds[i],
        children,
        nodes,
        level + 1,
        angle,
        angleRange * 0.6,
      );
    }
  }
}
