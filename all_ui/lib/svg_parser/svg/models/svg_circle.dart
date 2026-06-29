import 'dart:ui';

import 'svg_element.dart';

class SvgCircle extends SvgElement {
  final double cx, cy, r;

  SvgCircle({
    required this.cx,
    required this.cy,
    required this.r,
    required super.style,
    super.transform,
  });

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    if (style.fill?.color != null && !style.fill!.isNone) {
      canvas.drawCircle(Offset(cx, cy), r, style.createFillPaint());
    }
    if (style.stroke?.color != null && !style.stroke!.isNone) {
      canvas.drawCircle(Offset(cx, cy), r, style.createStrokePaint());
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
