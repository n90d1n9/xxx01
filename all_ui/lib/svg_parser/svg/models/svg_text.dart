import 'package:flutter/material.dart';

import 'svg_element.dart';

class SvgText extends SvgElement {
  final double x, y;
  final String text;
  final double fontSize;
  final String fontFamily;
  final String? fontWeight;
  final String? textAnchor;

  SvgText({
    required this.x,
    required this.y,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    this.fontWeight,
    this.textAnchor,
    required super.style,
    super.transform,
  });

  @override
  void paint(Canvas canvas, Size size, Map<String, dynamic> defs) {
    applyTransform(canvas);

    final textStyle = TextStyle(
      color: style.fill?.color ?? Colors.black,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight == 'bold' ? FontWeight.bold : FontWeight.normal,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    double offsetX = x;
    if (textAnchor == 'middle') {
      offsetX -= textPainter.width / 2;
    } else if (textAnchor == 'end') {
      offsetX -= textPainter.width;
    }

    textPainter.paint(canvas, Offset(offsetX, y - textPainter.height));
    restoreTransform(canvas);
  }

  @override
  Rect getBounds() {
    // TODO: implement getBounds
    throw UnimplementedError();
  }
}
