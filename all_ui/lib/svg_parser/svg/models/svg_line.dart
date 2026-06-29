import 'dart:ui';

import 'svg_element.dart';

class SvgLine extends SvgElement {
  final double x1, y1, x2, y2;

  SvgLine({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required super.style,
    super.transform,
  });

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    if (style.stroke?.color != null && !style.stroke!.isNone) {
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        style.createStrokePaint(),
      );
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
