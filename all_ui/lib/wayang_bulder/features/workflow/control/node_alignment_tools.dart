import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/node/model/schema/node_data.dart';

class NodeAlignmentTools {
  static void alignLeft(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.isEmpty) return;
    final minX = nodes.map((n) => n.position.dx).reduce(math.min);
    for (final node in nodes) {
      updatePosition(node.id, Offset(minX, node.position.dy));
    }
  }

  static void alignRight(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.isEmpty) return;
    final maxX = nodes.map((n) => n.position.dx).reduce(math.max);
    for (final node in nodes) {
      updatePosition(node.id, Offset(maxX, node.position.dy));
    }
  }

  static void alignTop(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.isEmpty) return;
    final minY = nodes.map((n) => n.position.dy).reduce(math.min);
    for (final node in nodes) {
      updatePosition(node.id, Offset(node.position.dx, minY));
    }
  }

  static void alignBottom(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.isEmpty) return;
    final maxY = nodes.map((n) => n.position.dy).reduce(math.max);
    for (final node in nodes) {
      updatePosition(node.id, Offset(node.position.dx, maxY));
    }
  }

  static void distributeHorizontally(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.length < 3) return;

    final sortedNodes = List<NodeData>.from(nodes)
      ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
    final minX = sortedNodes.first.position.dx;
    final maxX = sortedNodes.last.position.dx;
    final spacing = (maxX - minX) / (sortedNodes.length - 1);

    for (var i = 1; i < sortedNodes.length - 1; i++) {
      final newX = minX + (spacing * i);
      updatePosition(
        sortedNodes[i].id,
        Offset(newX, sortedNodes[i].position.dy),
      );
    }
  }

  static void distributeVertically(
    List<NodeData> nodes,
    Function(String, Offset) updatePosition,
  ) {
    if (nodes.length < 3) return;

    final sortedNodes = List<NodeData>.from(nodes)
      ..sort((a, b) => a.position.dy.compareTo(b.position.dy));
    final minY = sortedNodes.first.position.dy;
    final maxY = sortedNodes.last.position.dy;
    final spacing = (maxY - minY) / (sortedNodes.length - 1);

    for (var i = 1; i < sortedNodes.length - 1; i++) {
      final newY = minY + (spacing * i);
      updatePosition(
        sortedNodes[i].id,
        Offset(sortedNodes[i].position.dx, newY),
      );
    }
  }
}
