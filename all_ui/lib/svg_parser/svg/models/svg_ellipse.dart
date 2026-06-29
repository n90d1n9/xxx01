import 'dart:ui';

import 'svg_element.dart';

class SvgEllipse extends SvgElement {
  final double cx, cy, rx, ry;

  SvgEllipse({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required super.style,
    super.transform,
  });

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );

    if (style.fill?.color != null && !style.fill!.isNone) {
      canvas.drawOval(rect, style.createFillPaint());
    }
    if (style.stroke?.color != null && !style.stroke!.isNone) {
      canvas.drawOval(rect, style.createStrokePaint());
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
