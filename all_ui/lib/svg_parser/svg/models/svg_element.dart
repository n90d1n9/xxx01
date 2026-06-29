import 'package:flutter/widgets.dart';

import 'svg_style.dart';

/// Base class for all SVG elements
abstract class SvgElement {
  final SvgStyle style;
  final Matrix4? transform;
  final String? id;
  final List<String>? classes;

  // Interactive properties
  final VoidCallback? onClick;
  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;
  final VoidCallback? onLongPress;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;

  SvgElement({
    required this.style,
    this.transform,
    this.id,
    this.classes,
    this.onClick,
    this.onHover,
    this.onHoverExit,
    this.onLongPress,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
  });

  /// Paint the element to canvas
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs);

  /// Get the bounding box of the element
  Rect getBounds();

  /// Check if a point is inside the element (for hit testing)
  bool hitTest(Offset position) {
    return getBounds().contains(position);
  }

  /// Apply transformation to canvas
  void applyTransform(Canvas canvas) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform!.storage);
    }
  }

  /// Restore transformation
  void restoreTransform(Canvas canvas) {
    if (transform != null) {
      canvas.restore();
    }
  }
}
