import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';

class SmartAlignmentGuides extends ConsumerWidget {
  const SmartAlignmentGuides({super.key});

  static const _snapThreshold = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final showPrecisionGuides = ref.watch(
      canvasViewportProvider.select((state) => state.showPrecisionGuides),
    );
    final selectedComponents = layoutState.selectedComponents
        .where((component) => component.isVisible)
        .toList(growable: false);

    if (selectedComponents.isEmpty) return const SizedBox.shrink();

    final selectedIds =
        selectedComponents.map((component) => component.id).toSet();
    final targetBounds = _componentsBounds(selectedComponents);
    final comparisonComponents = layoutState.components
        .where(
          (component) =>
              component.isVisible && !selectedIds.contains(component.id),
        )
        .toList(growable: false);

    if (comparisonComponents.isEmpty) return const SizedBox.shrink();

    final guides = _buildGuides(targetBounds, comparisonComponents);
    if (guides.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _SmartGuidePainter(
          guides: guides,
          color: Theme.of(context).colorScheme.tertiary,
          showLabels: showPrecisionGuides,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  List<_SmartGuide> _buildGuides(
    Rect targetBounds,
    List<ComponentData> components,
  ) {
    final guides = <_SmartGuide>[];
    final seenKeys = <String>{};
    final targetVerticalAnchors = [
      _Anchor(targetBounds.left, targetBounds.top, targetBounds.bottom),
      _Anchor(targetBounds.center.dx, targetBounds.top, targetBounds.bottom),
      _Anchor(targetBounds.right, targetBounds.top, targetBounds.bottom),
    ];
    final targetHorizontalAnchors = [
      _Anchor(targetBounds.top, targetBounds.left, targetBounds.right),
      _Anchor(targetBounds.center.dy, targetBounds.left, targetBounds.right),
      _Anchor(targetBounds.bottom, targetBounds.left, targetBounds.right),
    ];

    for (final component in components) {
      final bounds = _componentBounds(component);
      final verticalAnchors = [
        _Anchor(bounds.left, bounds.top, bounds.bottom),
        _Anchor(bounds.center.dx, bounds.top, bounds.bottom),
        _Anchor(bounds.right, bounds.top, bounds.bottom),
      ];
      final horizontalAnchors = [
        _Anchor(bounds.top, bounds.left, bounds.right),
        _Anchor(bounds.center.dy, bounds.left, bounds.right),
        _Anchor(bounds.bottom, bounds.left, bounds.right),
      ];

      for (final targetAnchor in targetVerticalAnchors) {
        for (final anchor in verticalAnchors) {
          if ((targetAnchor.position - anchor.position).abs() >
              _snapThreshold) {
            continue;
          }

          final key = 'v:${anchor.position.round()}';
          if (!seenKeys.add(key)) continue;

          guides.add(
            _SmartGuide(
              axis: Axis.vertical,
              position: anchor.position,
              start: _min(targetAnchor.start, anchor.start),
              end: _max(targetAnchor.end, anchor.end),
            ),
          );
        }
      }

      for (final targetAnchor in targetHorizontalAnchors) {
        for (final anchor in horizontalAnchors) {
          if ((targetAnchor.position - anchor.position).abs() >
              _snapThreshold) {
            continue;
          }

          final key = 'h:${anchor.position.round()}';
          if (!seenKeys.add(key)) continue;

          guides.add(
            _SmartGuide(
              axis: Axis.horizontal,
              position: anchor.position,
              start: _min(targetAnchor.start, anchor.start),
              end: _max(targetAnchor.end, anchor.end),
            ),
          );
        }
      }
    }

    return guides;
  }
}

class _SmartGuidePainter extends CustomPainter {
  final List<_SmartGuide> guides;
  final Color color;
  final bool showLabels;

  const _SmartGuidePainter({
    required this.guides,
    required this.color,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.78)
          ..strokeWidth = 1.25
          ..strokeCap = StrokeCap.round;
    final endpointPaint =
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;
    final labelFill =
        Paint()
          ..color = color.withValues(alpha: 0.92)
          ..style = PaintingStyle.fill;

    for (final guide in guides) {
      if (guide.axis == Axis.vertical) {
        final start = Offset(guide.position, guide.start);
        final end = Offset(guide.position, guide.end);
        canvas.drawLine(start, end, paint);
        canvas.drawCircle(start, 2.5, endpointPaint);
        canvas.drawCircle(end, 2.5, endpointPaint);
        if (showLabels) {
          _paintGuideLabel(
            canvas,
            Offset(guide.position + 6, _labelAnchor(guide.start, guide.end)),
            'X ${guide.position.round()}',
            labelFill,
          );
        }
      } else {
        final start = Offset(guide.start, guide.position);
        final end = Offset(guide.end, guide.position);
        canvas.drawLine(start, end, paint);
        canvas.drawCircle(start, 2.5, endpointPaint);
        canvas.drawCircle(end, 2.5, endpointPaint);
        if (showLabels) {
          _paintGuideLabel(
            canvas,
            Offset(_labelAnchor(guide.start, guide.end), guide.position + 6),
            'Y ${guide.position.round()}',
            labelFill,
          );
        }
      }
    }
  }

  double _labelAnchor(double start, double end) {
    return start + (end - start).abs() * 0.5;
  }

  void _paintGuideLabel(
    Canvas canvas,
    Offset anchor,
    String label,
    Paint fill,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromLTWH(
      anchor.dx,
      anchor.dy,
      textPainter.width + 10,
      textPainter.height + 6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      fill,
    );
    textPainter.paint(canvas, rect.topLeft + const Offset(5, 3));
  }

  @override
  bool shouldRepaint(_SmartGuidePainter oldDelegate) {
    return oldDelegate.guides != guides ||
        oldDelegate.color != color ||
        oldDelegate.showLabels != showLabels;
  }
}

class _SmartGuide {
  final Axis axis;
  final double position;
  final double start;
  final double end;

  const _SmartGuide({
    required this.axis,
    required this.position,
    required this.start,
    required this.end,
  });
}

class _Anchor {
  final double position;
  final double start;
  final double end;

  const _Anchor(this.position, this.start, this.end);
}

Rect _componentsBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    final componentRight = component.position.dx + component.size.width;
    final componentBottom = component.position.dy + component.size.height;
    if (component.position.dx < left) left = component.position.dx;
    if (component.position.dy < top) top = component.position.dy;
    if (componentRight > right) right = componentRight;
    if (componentBottom > bottom) bottom = componentBottom;
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

Rect _componentBounds(ComponentData component) {
  return Rect.fromLTWH(
    component.position.dx,
    component.position.dy,
    component.size.width,
    component.size.height,
  );
}

double _min(double a, double b) => a < b ? a : b;

double _max(double a, double b) => a > b ? a : b;
