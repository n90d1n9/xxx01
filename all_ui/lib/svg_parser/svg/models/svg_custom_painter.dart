// CustomPainter implementation
import 'package:flutter/widgets.dart';

import 'svg_data.dart';

class SvgCustomPainter extends CustomPainter {
  final SvgData svgData;
  final BoxFit fit;
  final Alignment alignment;
  final bool clipToViewBox;

  SvgCustomPainter(
    this.svgData, {
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.clipToViewBox = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (svgData.elements.isEmpty) return;

    final viewBox = svgData.viewBox;
    final srcWidth = viewBox?[2] ?? svgData.width;
    final srcHeight = viewBox?[3] ?? svgData.height;
    final srcX = viewBox?[0] ?? 0.0;
    final srcY = viewBox?[1] ?? 0.0;

    // Calculate scaling and positioning
    final srcSize = Size(srcWidth, srcHeight);
    final dstSize = size;

    final fittedSizes = applyBoxFit(fit, srcSize, dstSize);
    final srcRect = Rect.fromLTWH(srcX, srcY, srcWidth, srcHeight);
    final dstRect = alignment.inscribe(
      fittedSizes.destination,
      Offset.zero & dstSize,
    );

    canvas.save();

    // Clip to bounds if needed
    if (clipToViewBox) {
      canvas.clipRect(Offset.zero & size);
    }

    // Apply transformation
    final scaleX = dstRect.width / srcRect.width;
    final scaleY = dstRect.height / srcRect.height;

    canvas.translate(dstRect.left, dstRect.top);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-srcRect.left, -srcRect.top);

    // Paint all elements
    for (var element in svgData.elements) {
      element.paint(canvas, Size(srcWidth, srcHeight), {});
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SvgCustomPainter oldDelegate) {
    return oldDelegate.svgData != svgData ||
        oldDelegate.fit != fit ||
        oldDelegate.alignment != alignment ||
        oldDelegate.clipToViewBox != clipToViewBox;
  }
}
