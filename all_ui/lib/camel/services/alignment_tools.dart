// Alignment Tools
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/node_card.dart';

enum AlignmentType {
  left,
  right,
  top,
  bottom,
  centerH,
  centerV,
  distributeH,
  distributeV,
}

class AlignmentTools {
  static void alignNodes(List<NodeCard> nodes, AlignmentType type) {
    if (nodes.length < 2) return;

    switch (type) {
      case AlignmentType.left:
        final minX = nodes.map((n) => n.position.dx).reduce(math.min);
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(minX, nodes[i].position.dy),
          );
        }
        break;
      case AlignmentType.right:
        final maxX = nodes.map((n) => n.position.dx).reduce(math.max);
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(maxX, nodes[i].position.dy),
          );
        }
        break;
      case AlignmentType.top:
        final minY = nodes.map((n) => n.position.dy).reduce(math.min);
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(nodes[i].position.dx, minY),
          );
        }
        break;
      case AlignmentType.bottom:
        final maxY = nodes.map((n) => n.position.dy).reduce(math.max);
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(nodes[i].position.dx, maxY),
          );
        }
        break;
      case AlignmentType.centerH:
        final avgY =
            nodes.map((n) => n.position.dy).reduce((a, b) => a + b) /
            nodes.length;
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(nodes[i].position.dx, avgY),
          );
        }
        break;
      case AlignmentType.centerV:
        final avgX =
            nodes.map((n) => n.position.dx).reduce((a, b) => a + b) /
            nodes.length;
        for (int i = 0; i < nodes.length; i++) {
          nodes[i] = nodes[i].copyWith(
            position: Offset(avgX, nodes[i].position.dy),
          );
        }
        break;
      case AlignmentType.distributeH:
        final sorted = List<NodeCard>.from(nodes)
          ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
        final minX = sorted.first.position.dx;
        final maxX = sorted.last.position.dx;
        final spacing = (maxX - minX) / (sorted.length - 1);
        for (int i = 0; i < sorted.length; i++) {
          sorted[i] = sorted[i].copyWith(
            position: Offset(minX + i * spacing, sorted[i].position.dy),
          );
        }
        nodes.clear();
        nodes.addAll(sorted);
        break;
      case AlignmentType.distributeV:
        final sorted = List<NodeCard>.from(nodes)
          ..sort((a, b) => a.position.dy.compareTo(b.position.dy));
        final minY = sorted.first.position.dy;
        final maxY = sorted.last.position.dy;
        final spacing = (maxY - minY) / (sorted.length - 1);
        for (int i = 0; i < sorted.length; i++) {
          sorted[i] = sorted[i].copyWith(
            position: Offset(sorted[i].position.dx, minY + i * spacing),
          );
        }
        nodes.clear();
        nodes.addAll(sorted);
        break;
    }
  }
}
