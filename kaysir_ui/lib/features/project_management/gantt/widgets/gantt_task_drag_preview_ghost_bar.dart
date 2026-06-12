import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_task_drag_preview_ghost_bar_service.dart';
import 'gantt_task_drag_preview_visuals.dart';

/// Compact timeline ghost that compares a task's original and target dates.
class GanttTaskDragPreviewGhostBar extends StatelessWidget {
  const GanttTaskDragPreviewGhostBar({
    required this.preview,
    required this.visuals,
    super.key,
  });

  static const barKey = ValueKey('gantt-task-drag-preview-ghost-bar');
  static const originalBarKey = ValueKey(
    'gantt-task-drag-preview-original-ghost-bar',
  );
  static const targetBarKey = ValueKey(
    'gantt-task-drag-preview-target-ghost-bar',
  );
  static const connectorKey = ValueKey(
    'gantt-task-drag-preview-ghost-bar-connector',
  );

  final ky.KyGanttTaskDragPreview preview;
  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    final geometry = const GanttTaskDragPreviewGhostBarGeometryService()
        .geometryFor(preview);

    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          key: barKey,
          decoration: BoxDecoration(
            color: visuals.foreground.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: visuals.foreground.withValues(alpha: 0.09),
            ),
          ),
          child: SizedBox(
            height: 42,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomPaint(
                          painter: _GanttGhostBarGridPainter(
                            color: visuals.foreground.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                    ),
                    _GhostConnector(
                      width: width,
                      geometry: geometry,
                      visuals: visuals,
                    ),
                    _GhostBarSegment(
                      key: originalBarKey,
                      width: width,
                      startFraction: geometry.originalStartFraction,
                      widthFraction: geometry.originalWidthFraction,
                      top: 12,
                      height: 14,
                      color: visuals.foreground.withValues(alpha: 0.18),
                      borderColor: visuals.foreground.withValues(alpha: 0.16),
                    ),
                    _GhostBarSegment(
                      key: targetBarKey,
                      width: width,
                      startFraction: geometry.targetStartFraction,
                      widthFraction: geometry.targetWidthFraction,
                      top: 18,
                      height: 16,
                      color: visuals.accent.withValues(alpha: 0.88),
                      borderColor: visuals.accent,
                      shadowColor: visuals.shadow,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded visual segment for either the original or proposed task range.
class _GhostBarSegment extends StatelessWidget {
  const _GhostBarSegment({
    required super.key,
    required this.width,
    required this.startFraction,
    required this.widthFraction,
    required this.top,
    required this.height,
    required this.color,
    required this.borderColor,
    this.shadowColor,
  });

  final double width;
  final double startFraction;
  final double widthFraction;
  final double top;
  final double height;
  final Color color;
  final Color borderColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final availableWidth = math.max(width - 20, 0.0);
    final left = 10 + (availableWidth * startFraction);
    final segmentWidth = math.max(availableWidth * widthFraction, 18.0);
    final renderedWidth =
        math.min(segmentWidth, math.max(width - left - 10, 0.0)).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: renderedWidth,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
          boxShadow:
              shadowColor == null
                  ? null
                  : [
                    BoxShadow(
                      color: shadowColor!,
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
        ),
      ),
    );
  }
}

/// Directional connector between the original and proposed task positions.
class _GhostConnector extends StatelessWidget {
  const _GhostConnector({
    required this.width,
    required this.geometry,
    required this.visuals,
  });

  final double width;
  final GanttTaskDragPreviewGhostBarGeometry geometry;
  final GanttTaskDragPreviewVisuals visuals;

  @override
  Widget build(BuildContext context) {
    if (!geometry.hasDateChange || geometry.connectorWidthFraction <= 0) {
      return const SizedBox.shrink();
    }

    final availableWidth = math.max(width - 20, 0.0);
    final left = 10 + (availableWidth * geometry.connectorStartFraction);
    final connectorWidth = math.max(
      availableWidth * geometry.connectorWidthFraction,
      24.0,
    );
    final renderedWidth =
        math.min(connectorWidth, math.max(width - left - 10, 0.0)).toDouble();
    final icon =
        geometry.targetMovesLater
            ? Icons.arrow_forward_rounded
            : Icons.arrow_back_rounded;

    return Positioned(
      key: GanttTaskDragPreviewGhostBar.connectorKey,
      left: left,
      top: 14,
      width: renderedWidth,
      height: 18,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              color: visuals.accent.withValues(alpha: 0.42),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: visuals.accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 13, color: visuals.background),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: visuals.accent.withValues(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight grid painter that gives the ghost bar a timeline reference.
class _GanttGhostBarGridPainter extends CustomPainter {
  const _GanttGhostBarGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    const divisions = 6;
    for (var i = 1; i < divisions; i += 1) {
      final x = size.width * (i / divisions);
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GanttGhostBarGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
