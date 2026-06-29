import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../schema/layer/designer_layer.dart';
import '../schema/layer/layer.dart';

class CanvasPainter extends CustomPainter {
  final List<DesignerLayer> layers;
  final DesignerLayer? selectedLayer;
  final double currentTime;

  CanvasPainter({
    required this.layers,
    this.selectedLayer,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);

    // Draw layers
    for (var layer in layers) {
      if (!layer.visible) continue;

      canvas.save();

      // Apply transforms
      canvas.translate(layer.position.dx, layer.position.dy);
      canvas.rotate(layer.rotation * math.pi / 180);
      canvas.scale(layer.scale);

      final paint =
          Paint()
            ..color = layer.color.withOpacity(layer.opacity)
            ..style = PaintingStyle.fill;

      // Draw based on type
      switch (layer.type) {
        case LayerType.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: layer.size.width,
              height: layer.size.height,
            ),
            paint,
          );
          break;

        case LayerType.circle:
          canvas.drawCircle(Offset.zero, layer.size.width / 2, paint);
          break;

        case LayerType.ellipse:
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: layer.size.width,
              height: layer.size.height,
            ),
            paint,
          );
          break;

        default:
          break;
      }

      canvas.restore();

      // Draw selection indicator
      if (layer == selectedLayer) {
        _drawSelection(canvas, layer);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 0.5;

    const gridSize = 20.0;

    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawSelection(Canvas canvas, DesignerLayer layer) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromCenter(
        center: layer.position,
        width: layer.size.width * layer.scale + 10,
        height: layer.size.height * layer.scale + 10,
      ),
      paint,
    );

    // Draw corner handles
    final handlePaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final corners = [
      layer.position +
          Offset(
            -layer.size.width * layer.scale / 2,
            -layer.size.height * layer.scale / 2,
          ),
      layer.position +
          Offset(
            layer.size.width * layer.scale / 2,
            -layer.size.height * layer.scale / 2,
          ),
      layer.position +
          Offset(
            layer.size.width * layer.scale / 2,
            layer.size.height * layer.scale / 2,
          ),
      layer.position +
          Offset(
            -layer.size.width * layer.scale / 2,
            layer.size.height * layer.scale / 2,
          ),
    ];

    for (var corner in corners) {
      canvas.drawCircle(corner, 4, handlePaint);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.selectedLayer != selectedLayer ||
        oldDelegate.currentTime != currentTime;
  }
}
