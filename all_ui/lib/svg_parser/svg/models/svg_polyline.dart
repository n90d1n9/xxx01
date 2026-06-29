import 'package:flutter/widgets.dart';

import 'svg_element.dart';

class SvgPolyline extends SvgElement {
  final List<Offset> points;

  SvgPolyline({required this.points, required super.style, super.transform});

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    if (points.isEmpty) return;

    applyTransform(canvas);
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (style.fill?.color != null && !style.fill!.isNone) {
      canvas.drawPath(path, style.createFillPaint());
    }
    if (style.stroke?.color != null && !style.stroke!.isNone) {
      canvas.drawPath(path, style.createStrokePaint());
    }
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
