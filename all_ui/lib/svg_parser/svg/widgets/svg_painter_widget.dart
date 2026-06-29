// Usage widget with extensive customization
import 'package:flutter/material.dart';

import '../models/svg_custom_painter.dart';
import '../services/svg_parser.dart';

class SvgPainterWidget extends StatelessWidget {
  final String svgCode;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final bool clipToViewBox;
  final Color? color;

  const SvgPainterWidget({
    super.key,
    required this.svgCode,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.clipToViewBox = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final svgData = SvgParser.parse(svgCode);

      return CustomPaint(
        painter: SvgCustomPainter(
          svgData,
          fit: fit,
          alignment: alignment,
          clipToViewBox: clipToViewBox,
        ),
        size: Size(width ?? svgData.width, height ?? svgData.height),
      );
    } catch (e) {
      return Container(
        width: width ?? 100,
        height: height ?? 100,
        color: Colors.red.withOpacity(0.1),
        child: Center(child: Icon(Icons.error_outline, color: Colors.red)),
      );
    }
  }
}
