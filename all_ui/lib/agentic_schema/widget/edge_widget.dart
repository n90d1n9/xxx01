import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/workflow/workflow_edge.dart';
import '../state/canvas_provider.dart';
import '../state/workflow/workflow_provider.dart';

class EdgeWidget extends ConsumerWidget {
  final WorkflowEdge edge;
  final CanvasState canvasState;
  final bool isSelected;

  const EdgeWidget({
    super.key,
    required this.edge,
    required this.canvasState,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);

    // Find source and target nodes
    final sourceNode = workflowState.currentWorkflow?.nodes.firstWhere(
      (n) => n.id == edge.source,
    );
    final targetNode = workflowState.currentWorkflow?.nodes.firstWhere(
      (n) => n.id == edge.target,
    );

    if (sourceNode == null || targetNode == null) {
      return const SizedBox.shrink();
    }

    // Convert node positions to screen coordinates
    final sourcePos = canvasState.canvasToScreen(
      Offset(sourceNode.position.x, sourceNode.position.y),
    );
    final targetPos = canvasState.canvasToScreen(
      Offset(targetNode.position.x, targetNode.position.y),
    );

    return CustomPaint(
      painter: _EdgePainter(
        source: sourcePos,
        target: targetPos,
        isSelected: isSelected,
        edgeType: edge.type,
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  final Offset source;
  final Offset target;
  final bool isSelected;
  final EdgeType? edgeType;

  const _EdgePainter({
    required this.source,
    required this.target,
    required this.isSelected,
    this.edgeType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getEdgeColor()
      ..strokeWidth = isSelected ? 3.0 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a simple bezier curve between nodes
    final controlPoint1 = Offset(
      source.dx + (target.dx - source.dx) * 0.5,
      source.dy,
    );
    final controlPoint2 = Offset(
      source.dx + (target.dx - source.dx) * 0.5,
      target.dy,
    );

    final path = Path()
      ..moveTo(source.dx, source.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        target.dx,
        target.dy,
      );

    canvas.drawPath(path, paint);

    // Draw arrowhead at target
    _drawArrowhead(canvas, path, paint);
  }

  Color _getEdgeColor() {
    if (isSelected) return Colors.blue;

    return switch (edgeType) {
      EdgeType.conditional => Colors.orange,
      EdgeType.fallback => Colors.red,
      EdgeType.loop => Colors.purple,
      EdgeType.error => Colors.red,
      EdgeType.wireTap => Colors.grey,
      EdgeType.multicast => Colors.green,
      _ => Colors.grey.shade600,
    };
  }

  void _drawArrowhead(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    final pathMetric = pathMetrics.first;
    final tangent = pathMetric.getTangentForOffset(pathMetric.length - 10);

    if (tangent != null) {
      final arrowSize = 8.0;
      final arrowPath = Path();

      arrowPath.moveTo(tangent.position.dx, tangent.position.dy);
      arrowPath.lineTo(
        tangent.position.dx - arrowSize,
        tangent.position.dy - arrowSize,
      );
      arrowPath.lineTo(
        tangent.position.dx - arrowSize,
        tangent.position.dy + arrowSize,
      );
      arrowPath.close();

      canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
