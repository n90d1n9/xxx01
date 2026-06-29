import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/node/model/schema/node_data.dart';
import '../components/node/model/node_group.dart';

class NodeGroupWidget extends StatelessWidget {
  final NodeGroup group;
  final List<NodeData> nodes;
  final VoidCallback onToggle;

  const NodeGroupWidget({
    super.key,
    required this.group,
    required this.nodes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    // Calculate bounds
    final minX = nodes.map((n) => n.position.dx).reduce(math.min);
    final maxX = nodes.map((n) => n.position.dx).reduce(math.max);
    final minY = nodes.map((n) => n.position.dy).reduce(math.min);
    final maxY = nodes.map((n) => n.position.dy).reduce(math.max);

    final width = maxX - minX + 300;
    final height = maxY - minY + 200;

    return Positioned(
      left: minX - 20,
      top: minY - 40,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: group.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: group.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: group.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        group.collapsed ? Icons.expand_more : Icons.expand_less,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
