import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../../../../config/config.dart';
import '../../../state/workflow_state.dart';

class ConnectionPreviewPainter extends CustomPainter {
  final WorkflowState workflowState;
  final String fromNodeId;
  final String fromPortId;
  final Offset mousePosition; // screen-space

  ConnectionPreviewPainter({
    required this.workflowState,
    required this.fromNodeId,
    required this.fromPortId,
    required this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sourceNode = workflowState.nodes.firstWhereOrNull(
      (n) => n.id == fromNodeId,
    );
    if (sourceNode == null) return;

    final portIndex = sourceNode.outputs.indexWhere((p) => p.id == fromPortId);
    if (portIndex == -1) return;

    // Output port: right side of node
    final portY =
        kNodeCardHeaderHeight +
        kNodeCardInternalPadding +
        (portIndex * kNodeCardPortSpacing);
    final portCanvasPos = sourceNode.position + Offset(kNodeCardWidth, portY);
    final startPoint =
        (portCanvasPos + workflowState.canvasOffset) * workflowState.zoom;

    // End point = mouse cursor (already in screen space)
    final endPoint = mousePosition;

    // Draw bezier
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final controlDistance = math.max(50.0, math.min(distance * 0.4, 150.0));

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..cubicTo(
        startPoint.dx + controlDistance,
        startPoint.dy,
        endPoint.dx - controlDistance,
        endPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6)
      ..strokeWidth = 2 * workflowState.zoom
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ConnectionPreviewPainter oldDelegate) => true;
}
