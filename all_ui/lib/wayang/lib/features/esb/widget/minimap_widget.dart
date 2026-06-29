import 'package:flutter/material.dart';

import '../model/connection.dart';
import '../model/integration_component.dart';
import 'minimap_painter.dart';

class MinimapWidget extends StatelessWidget {
  final List<IntegrationComponent> components;
  final List<Connection> connections;

  const MinimapWidget({
    super.key,
    required this.components,
    required this.connections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: MinimapPainter(components, connections)),
    );
  }
}
