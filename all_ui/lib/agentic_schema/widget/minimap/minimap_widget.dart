import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import 'minimap_painter.dart';

class MinimapWidget extends ConsumerStatefulWidget {
  final Size canvasSize;

  const MinimapWidget({super.key, required this.canvasSize});

  @override
  ConsumerState<MinimapWidget> createState() => _MinimapWidgetState();
}

class _MinimapWidgetState extends ConsumerState<MinimapWidget> {
  static const double minimapWidth = 200;
  static const double minimapHeight = 150;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    final canvasState = ref.watch(canvasProvider);

    if (workflowState.currentWorkflow == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        width: minimapWidth,
        height: minimapHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: GestureDetector(
            onPanStart: (details) {
              _dragStart = details.localPosition;
            },
            onPanUpdate: (details) {
              if (_dragStart != null) {
                _handleMinimapPan(details.localPosition, canvasState);
              }
            },
            onPanEnd: (_) {
              _dragStart = null;
            },
            onTapDown: (details) {
              _handleMinimapTap(details.localPosition, canvasState);
            },
            child: CustomPaint(
              size: const Size(minimapWidth, minimapHeight),
              painter: MinimapPainter(
                nodes: workflowState.currentWorkflow!.nodes,
                edges: workflowState.currentWorkflow!.edges ?? [],
                canvasState: canvasState,
                viewportSize: widget.canvasSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleMinimapTap(Offset localPosition, CanvasState canvasState) {
    final bounds = _calculateWorkflowBounds(
      ref.read(workflowProvider).currentWorkflow!.nodes,
    );

    final scale = _calculateMinimapScale(bounds);
    final canvasPosition = Offset(
      (localPosition.dx / scale) + bounds.left,
      (localPosition.dy / scale) + bounds.top,
    );

    // Center the viewport on the tapped position
    final newPanOffset = Offset(
      widget.canvasSize.width / 2 - canvasPosition.dx * canvasState.zoom,
      widget.canvasSize.height / 2 - canvasPosition.dy * canvasState.zoom,
    );

    ref.read(canvasProvider.notifier).pan(newPanOffset - canvasState.panOffset);
  }

  void _handleMinimapPan(Offset localPosition, CanvasState canvasState) {
    if (_dragStart == null) return;
    _handleMinimapTap(localPosition, canvasState);
  }

  Rect _calculateWorkflowBounds(List<WorkflowNode> nodes) {
    if (nodes.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = node.position.x < minX ? node.position.x : minX;
      minY = node.position.y < minY ? node.position.y : minY;
      maxX = node.position.x + 200 > maxX ? node.position.x + 200 : maxX;
      maxY = node.position.y + 100 > maxY ? node.position.y + 100 : maxY;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _calculateMinimapScale(Rect bounds) {
    final scaleX = minimapWidth / bounds.width;
    final scaleY = minimapHeight / bounds.height;
    return scaleX < scaleY ? scaleX : scaleY;
  }
}
