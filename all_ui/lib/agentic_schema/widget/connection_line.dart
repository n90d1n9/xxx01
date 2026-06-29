import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/workflow/workflow_node.dart';
import '../state/canvas_provider.dart';
import '../state/ui_provider.dart';
import '../state/workflow/workflow_provider.dart';
import '../state/workflow/workflow_state.dart';

class ConnectionLine extends ConsumerWidget {
  final String startNodeId;
  final String? startHandleId;
  final CanvasState canvasState;

  const ConnectionLine({
    super.key,
    required this.startNodeId,
    required this.startHandleId,
    required this.canvasState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);
    final uiState = ref.watch(uiProvider);

    return MouseRegion(
      onHover: (event) {
        ref.read(uiProvider.notifier).updateCursorPosition(event.localPosition);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          // Update connection line while dragging
          ref
              .read(uiProvider.notifier)
              .updateCursorPosition(details.localPosition);
        },
        onPanEnd: (details) {
          // Complete connection or cancel
          ref.read(workflowProvider.notifier).cancelConnection();
        },
        child: CustomPaint(
          painter: ConnectionLinePainter(
            startNodeId: startNodeId,
            startHandleId: startHandleId,
            canvasState: canvasState,
            mousePosition: uiState.cursorPosition,
            workflowState: workflowState,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class ConnectionLinePainter extends CustomPainter {
  final String startNodeId;
  final String? startHandleId;
  final CanvasState canvasState;
  final Offset? mousePosition;
  final WorkflowState workflowState;

  const ConnectionLinePainter({
    required this.startNodeId,
    required this.startHandleId,
    required this.canvasState,
    required this.mousePosition,
    required this.workflowState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mousePosition == null) return;

    final startNode = workflowState.currentWorkflow?.nodes.firstWhereOrNull(
      (node) => node.id == startNodeId,
    );

    if (startNode == null) return;

    // Transform to canvas coordinates
    canvas.save();
    canvas.translate(canvasState.panOffset.dx, canvasState.panOffset.dy);
    canvas.scale(canvasState.zoom);

    // Calculate start position (from node center or specific handle)
    final start = _getNodeConnectionPoint(startNode, startHandleId);
    final end = canvasState.screenToCanvas(mousePosition!);

    // Draw connection line
    _drawConnectionLine(canvas, start, end);

    // Draw potential connection preview
    _drawConnectionPreview(canvas, end);

    canvas.restore();
  }

  Offset _getNodeConnectionPoint(WorkflowNode node, String? handleId) {
    const nodeWidth = 200.0;
    const nodeHeight = 100.0;

    if (handleId != null) {
      // Find specific handle position
      // TODO: Implement handle-based positioning when you add handles to WorkflowNode
      // For now, use node center
    }

    // Default to node center
    return Offset(
      node.position.x + nodeWidth / 2,
      node.position.y + nodeHeight / 2,
    );
  }

  void _drawConnectionLine(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed line for connection preview
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashLength = 10.0;
    final dashGap = 5.0;
    final totalLength = dashLength + dashGap;

    for (double i = 0; i < distance; i += totalLength) {
      final ratio = i / distance;
      final x = start.dx + dx * ratio;
      final y = start.dy + dy * ratio;

      if (i + dashLength <= distance) {
        final endRatio = (i + dashLength) / distance;
        final endX = start.dx + dx * endRatio;
        final endY = start.dy + dy * endRatio;
        path.lineTo(endX, endY);
      } else {
        path.lineTo(end.dx, end.dy);
      }

      if (i + totalLength < distance) {
        final gapRatio = (i + totalLength) / distance;
        final gapX = start.dx + dx * gapRatio;
        final gapY = start.dy + dy * gapRatio;
        path.moveTo(gapX, gapY);
      }
    }

    canvas.drawPath(path, paint);

    // Draw start circle
    final startPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 4, startPaint);

    // Draw end arrow
    _drawConnectionArrow(canvas, start, end);
  }

  void _drawConnectionArrow(Canvas canvas, Offset start, Offset end) {
    const arrowSize = 8.0;
    final direction = (end - start);
    final angle = math.atan2(direction.dy, direction.dx);

    final arrowPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  void _drawConnectionPreview(Canvas canvas, Offset end) {
    // Check if we're hovering over a valid target node
    final targetNode = _findNodeAtPosition(end, workflowState);

    if (targetNode != null && targetNode.id != startNodeId) {
      // Draw valid connection preview
      const nodeWidth = 200.0;
      const nodeHeight = 100.0;
      final targetRect = Rect.fromCenter(
        center: Offset(
          targetNode.position.x + nodeWidth / 2,
          targetNode.position.y + nodeHeight / 2,
        ),
        width: nodeWidth,
        height: nodeHeight,
      );

      final previewPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRect(targetRect, previewPaint);
      canvas.drawRect(targetRect, borderPaint);
    } else {
      // Draw invalid connection indicator
      final invalidPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(end, 6, invalidPaint);
    }
  }

  WorkflowNode? _findNodeAtPosition(
    Offset canvasPos,
    WorkflowState workflowState,
  ) {
    for (final node in workflowState.currentWorkflow?.nodes ?? []) {
      const nodeWidth = 200.0;
      const nodeHeight = 100.0;
      final nodeRect = Rect.fromCenter(
        center: Offset(
          node.position.x + nodeWidth / 2,
          node.position.y + nodeHeight / 2,
        ),
        width: nodeWidth,
        height: nodeHeight,
      );
      if (nodeRect.contains(canvasPos)) {
        return node;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) {
    return oldDelegate.startNodeId != startNodeId ||
        oldDelegate.startHandleId != startHandleId ||
        oldDelegate.canvasState != canvasState ||
        oldDelegate.mousePosition != mousePosition ||
        oldDelegate.workflowState != workflowState;
  }
}

// Add this extension for convenience
extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Add this extension for vector normalization
extension OffsetExtension on Offset {
  Offset get normalized {
    final length = distance;
    return length > 0 ? this / length : this;
  }
}
