// Style class
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'svg_paint.dart';

class SvgStyle {
  SvgPaint? fill;
  SvgPaint? stroke;
  double? strokeWidth;
  double? opacity;
  double? fillOpacity;
  double? strokeOpacity;
  StrokeCap? strokeLinecap;
  StrokeJoin? strokeLinejoin;
  double? strokeMiterlimit;
  List<double>? strokeDasharray;
  PathFillType? fillRule;

  SvgStyle({
    this.fill,
    this.stroke,
    this.strokeWidth = 1.0,
    this.opacity = 1.0,
    this.fillOpacity = 1.0,
    this.strokeOpacity = 1.0,
    this.strokeLinecap = StrokeCap.butt,
    this.strokeLinejoin = StrokeJoin.miter,
    this.strokeMiterlimit = 4.0,
    this.strokeDasharray,
    this.fillRule = PathFillType.nonZero,
  }) {
    fill ??= SvgPaint.color(Colors.black);
  }

  SvgStyle.from(SvgStyle other)
    : fill = other.fill,
      stroke = other.stroke,
      strokeWidth = other.strokeWidth,
      opacity = other.opacity,
      fillOpacity = other.fillOpacity,
      strokeOpacity = other.strokeOpacity,
      strokeLinecap = other.strokeLinecap,
      strokeLinejoin = other.strokeLinejoin,
      strokeMiterlimit = other.strokeMiterlimit,
      strokeDasharray = other.strokeDasharray,
      fillRule = other.fillRule;

  Paint createFillPaint() {
    final paint = Paint()..style = PaintingStyle.fill;

    if (fill?.color != null) {
      final totalOpacity = (opacity ?? 1.0) * (fillOpacity ?? 1.0);
      paint.color = fill!.color!.withOpacity(
        fill!.color!.opacity * totalOpacity,
      );
    }

    return paint;
  }

  Paint createStrokePaint() {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth ?? 1.0
          ..strokeCap = strokeLinecap ?? StrokeCap.butt
          ..strokeJoin = strokeLinejoin ?? StrokeJoin.miter
          ..strokeMiterLimit = strokeMiterlimit ?? 4.0;

    if (stroke?.color != null) {
      final totalOpacity = (opacity ?? 1.0) * (strokeOpacity ?? 1.0);
      paint.color = stroke!.color!.withOpacity(
        stroke!.color!.opacity * totalOpacity,
      );
    }

    return paint;
  }
}
