import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'svg_element.dart';

/// SVG Image element for embedding images
class SvgImage extends SvgElement {
  final String href;
  final double x, y, width, height;
  final String? preserveAspectRatio;
  ui.Image? _cachedImage;

  SvgImage({
    required this.href,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.preserveAspectRatio,
    required super.style,
    super.transform,
    super.id,
    super.classes,
    super.onClick,
    super.onHover,
    super.onHoverExit,
    super.onLongPress,
    super.onTap,
    super.onTapDown,
    super.onTapUp,
  });

  /// Load image from URL or data URI
  Future<void> loadImage() async {
    if (href.startsWith('data:')) {
      // Handle data URI
      // TODO: Implement data URI parsing and image loading
    } else {
      // Handle external URL
      // TODO: Implement network image loading
    }
  }

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    canvas.save();
    applyTransform(canvas);

    final rect = Rect.fromLTWH(x, y, width, height);

    if (_cachedImage != null) {
      // Draw loaded image
      paintImage(
        canvas: canvas,
        rect: rect,
        image: _cachedImage!,
        fit: BoxFit.cover,
      );
    } else {
      // Draw placeholder
      final paint = Paint()..color = Colors.grey.withOpacity(0.3);
      canvas.drawRect(rect, paint);

      // Draw icon placeholder
      final iconPaint =
          Paint()
            ..color = Colors.grey
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      final centerX = x + width / 2;
      final centerY = y + height / 2;
      final iconSize = math.min(width, height) * 0.3;

      canvas.drawCircle(Offset(centerX, centerY), iconSize, iconPaint);
    }

    canvas.restore();
  }

  @override
  Rect getBounds() => Rect.fromLTWH(x, y, width, height);

  @override
  String toString() => 'SvgImage(href: $href, ${width}x$height)';
}
