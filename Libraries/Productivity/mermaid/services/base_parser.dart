import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/mermaid_diagram.dart';

abstract class DiagramParser {
  MermaidDiagram parse(List<String> lines, String rawCode);
  bool canParse(List<String> lines);
}

mixin LayoutMixin {
  void layoutNodes(List<DiagramNode> nodes, List<DiagramEdge> edges) {
    _layoutHierarchical(nodes, edges);
  }

  void layoutNodesInGrid(
    List<DiagramNode> nodes, {
    int itemsPerRow = 3,
    double spacingX = 280.0,
    double spacingY = 300.0,
    double startY = 50.0,
  }) {
    _layoutGrid(
      nodes,
      itemsPerRow: itemsPerRow,
      spacingX: spacingX,
      spacingY: spacingY,
      startY: startY,
    );
  }

  void _layoutHierarchical(
    List<DiagramNode> nodes,
    List<DiagramEdge> edges, {
    double nodeSpacingX = 250.0,
    double nodeSpacingY = 180.0,
  }) {
    if (nodes.isEmpty) return;

    final levels = <String, int>{};
    final visited = <String>{};

    void assignLevel(String nodeId, int level) {
      if (visited.contains(nodeId)) return;
      visited.add(nodeId);
      levels[nodeId] = math.max(levels[nodeId] ?? 0, level);

      for (final edge in edges.where((e) => e.from == nodeId)) {
        assignLevel(edge.to, level + 1);
      }
    }

    final hasIncoming = edges.map((e) => e.to).toSet();
    final roots =
        nodes
            .where((n) => !hasIncoming.contains(n.id))
            .map((n) => n.id)
            .toList();

    if (roots.isEmpty && nodes.isNotEmpty) {
      assignLevel(nodes.first.id, 0);
    } else {
      for (final root in roots) {
        assignLevel(root, 0);
      }
    }

    final nodesByLevel = <int, List<DiagramNode>>{};
    for (final node in nodes) {
      final level = levels[node.id] ?? 0;
      nodesByLevel.putIfAbsent(level, () => []).add(node);
    }

    for (final entry in nodesByLevel.entries) {
      final level = entry.key;
      final levelNodes = entry.value;
      final levelWidth = levelNodes.length * nodeSpacingX;
      final startX = (800 - levelWidth) / 2;

      for (var i = 0; i < levelNodes.length; i++) {
        final node = levelNodes[i];
        node.copyWith(
          position: Offset(
            startX + i * nodeSpacingX,
            level * nodeSpacingY + 100,
          ),
        );
      }
    }
  }

  void _layoutGrid(
    List<DiagramNode> nodes, {
    int itemsPerRow = 3,
    double spacingX = 280.0,
    double spacingY = 300.0,
    double startY = 50.0,
  }) {
    final rows = <int, List<DiagramNode>>{};
    var row = 0;
    var col = 0;

    for (final node in nodes) {
      rows.putIfAbsent(row, () => []).add(node);
      col++;
      if (col >= itemsPerRow) {
        row++;
        col = 0;
      }
    }

    for (final entry in rows.entries) {
      final rowIndex = entry.key;
      final rowNodes = entry.value;
      final rowWidth = rowNodes.length * spacingX;
      final startX = (1000 - rowWidth) / 2;

      for (var i = 0; i < rowNodes.length; i++) {
        rowNodes[i].copyWith(
          position: Offset(startX + i * spacingX, rowIndex * spacingY + startY),
        );
      }
    }
  }

  void layoutRadial(
    DiagramNode root,
    List<DiagramNode> nodes,
    List<DiagramEdge> edges, {
    double initialRadius = 120.0,
    double radiusIncrement = 80.0,
  }) {
    final children = <String, List<String>>{};
    for (final edge in edges) {
      children.putIfAbsent(edge.from, () => []).add(edge.to);
    }

    void layoutChildren(
      String nodeId,
      int level,
      double startAngle,
      double angleRange,
    ) {
      final childIds = children[nodeId] ?? [];
      if (childIds.isEmpty) return;

      final angleStep = angleRange / math.max(1, childIds.length - 1);
      final parentNode = nodes.firstWhere((n) => n.id == nodeId);
      final radius = initialRadius + level * radiusIncrement;

      for (var i = 0; i < childIds.length; i++) {
        final childNode = nodes.firstWhere((n) => n.id == childIds[i]);
        final angle = startAngle - angleRange / 2 + angleStep * i;

        childNode.copyWith(
          position: Offset(
            parentNode.position.dx + radius * math.cos(angle),
            parentNode.position.dy + radius * math.sin(angle),
          ),
        );

        layoutChildren(childIds[i], level + 1, angle, angleRange * 0.6);
      }
    }

    layoutChildren(root.id, 1, -math.pi / 2, math.pi);
  }
}
