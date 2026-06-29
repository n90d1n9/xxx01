import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../state/workflow_state.dart';

enum ConnectionLineType { curved, bezier, elbow, straight, stepped }

class ConnectionsPainter extends CustomPainter {
  final WorkflowState workflowState;
  final ConnectionLineType lineType;
  final bool isSelected;
  final Color color;
  ConnectionsPainter({
    required this.workflowState,
    this.lineType = ConnectionLineType.curved,
    this.isSelected = false,
    this.color = Colors.blueAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in workflowState.connections) {
      final sourceNode = workflowState.nodes.firstWhere(
        (n) => n.id == connection.sourceNodeId,
        orElse: () => workflowState.nodes.first,
      );
      final targetNode = workflowState.nodes.firstWhere(
        (n) => n.id == connection.targetNodeId,
        orElse: () => workflowState.nodes.first,
      );

      final start =
          (sourceNode.position +
              workflowState.canvasOffset +
              const Offset(220, 60)) *
          workflowState.zoom;
      final end =
          (targetNode.position +
              workflowState.canvasOffset +
              const Offset(0, 40)) *
          workflowState.zoom;

      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.6)
        ..strokeWidth = 2 * workflowState.zoom
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(start.dx, start.dy);

      final distance = (end.dx - start.dx).abs();
      final controlOffset = math.min(distance * 0.5, 100.0);

      final control1 = Offset(start.dx + controlOffset, start.dy);
      final control2 = Offset(end.dx - controlOffset, end.dy);

      //
      /*     final paint = Paint()
      ..color = color
      ..strokeWidth = (isSelected ? 3.0 : 2.0) * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path(); */

      switch (lineType) {
        case ConnectionLineType.straight:
          path.moveTo(start.dx, start.dy);
          path.lineTo(end.dx, end.dy);
          break;

        case ConnectionLineType.curved:
          path.moveTo(start.dx, start.dy);
          path.cubicTo(
            control1.dx,
            control1.dy,
            control2.dx,
            control2.dy,
            end.dx,
            end.dy,
          );
          break;

        case ConnectionLineType.elbow:
          path.moveTo(start.dx, start.dy);
          path.lineTo(control1.dx, control1.dy); // Horizontal to middle
          path.lineTo(control2.dx, control2.dy); // Vertical to end Y
          path.lineTo(end.dx, end.dy); // Horizontal to end
          break;

        case ConnectionLineType.stepped:
          final stepSize = 40.0 * workflowState.zoom;
          path.moveTo(start.dx, start.dy);
          path.lineTo(start.dx + stepSize, start.dy); // First horizontal
          path.lineTo(start.dx + stepSize, control1.dy); // Vertical to middle
          path.lineTo(end.dx - stepSize, control2.dy); // Horizontal to end area
          path.lineTo(end.dx - stepSize, end.dy); // Vertical to end Y
          path.lineTo(end.dx, end.dy); // Final horizontal
          break;
        case ConnectionLineType.bezier:
          path.moveTo(start.dx, start.dy);
          path.cubicTo(
            control1.dx,
            control1.dy,
            control2.dx,
            control2.dy,
            end.dx,
            end.dy,
          );
          break;
      }

      canvas.drawPath(path, paint);

      // Draw selection highlight
      if (isSelected) {
        final highlightPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = 8.0 * workflowState.zoom
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(path, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) => true;
}
