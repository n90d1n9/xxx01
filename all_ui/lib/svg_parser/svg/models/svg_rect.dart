import 'dart:ui';

import 'svg_element.dart';

class SvgRect extends SvgElement {
  final double x, y, width, height, rx, ry;

  SvgRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rx,
    required this.ry,
    required super.style,
    super.transform,
  });

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);
    final rect = Rect.fromLTWH(x, y, width, height);

    if (rx > 0 || ry > 0) {
      final rRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(rx > 0 ? rx : ry),
      );
      if (style.fill?.color != null && !style.fill!.isNone) {
        canvas.drawRRect(rRect, style.createFillPaint());
      }
      if (style.stroke?.color != null && !style.stroke!.isNone) {
        canvas.drawRRect(rRect, style.createStrokePaint());
      }
    } else {
      if (style.fill?.color != null && !style.fill!.isNone) {
        canvas.drawRect(rect, style.createFillPaint());
      }
      if (style.stroke?.color != null && !style.stroke!.isNone) {
        canvas.drawRect(rect, style.createStrokePaint());
      }
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
